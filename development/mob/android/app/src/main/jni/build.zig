// build.zig — Android native build for mishka_mob.
//
// Phase 2 of the build-system migration. Owns the full native build:
//
//   Compile (zig cc / zig, per-ABI):
//     - driver_tab_android.zig  — static-NIF table (per-app generated;
//       legacy .c also supported — extension auto-detected)
//     - $MOB_DIR/android/jni/mob_nif.zig  (Phase 6b iter 3d — full
//       NIF surface in Zig; mob_nif.c deleted)
//     - $MOB_DIR/android/jni/mob_beam.zig (Phase 6b iter 2 — Zig)
//     - android/app/src/main/jni/beam_jni.c (in-project, still C —
//       just the JNI entrypoints + g_jvm/g_activity globals)
//
//   Link (zig cc -shared):
//     all 4 .o files + OTP/crypto static libs + Android system libs
//     (libandroid, liblog, libz, libc++_static, libc++abi).
//     Output: libmishka_mob.so installed to
//     android/app/src/main/jniLibs/<abi>/libmishka_mob.so so
//     Gradle picks it up via the default jniLibs.srcDirs scan.
//
// Per-ABI invocation by Mix's NativeBuild before gradle_assemble:
//
//   zig build native-lib \
//       -Dabi=arm64-v8a \
//       -Dotp_dir=$OTP_RELEASE \
//       -Derts_vsn=$ERTS_VSN \
//       -Dmob_dir=$MOB_DIR \
//       -Ddriver_tab=$DRIVER_TAB_ANDROID \
//       -Dproject_jni_dir=$(pwd)/android/app/src/main/jni \
//       -Dndk_sysroot=$NDK_SYSROOT \
//       -Dapp_name=mishka_mob \
//       -Dproject_root=$(pwd)
//
// Steps:
//   `zig build c-objects`  — compile only, .o files in zig-out/<abi>/
//   `zig build native-lib` — compile + link, lib<app>.so in jniLibs/<abi>/
//
// CMakeLists.txt sees the lib<app>.so already in jniLibs/ and skips
// building its own add_library target (still does sqlite3_nif).

const std = @import("std");

pub fn build(b: *std.Build) void {
    const abi = required(b, "abi", "Android ABI: arm64-v8a, armeabi-v7a, or x86_64");
    const otp_dir = required(b, "otp_dir", "Path to per-ABI Android OTP runtime");
    const erts_vsn = required(b, "erts_vsn", "ERTS version dir name (e.g. erts-17.0)");
    const mob_dir = required(b, "mob_dir", "Path to mob library");
    const driver_tab = required(b, "driver_tab", "Absolute path to driver_tab_android.{zig,c}");
    const project_jni_dir = required(b, "project_jni_dir", "Absolute path to the project's android/app/src/main/jni dir");
    const ndk_sysroot = required(b, "ndk_sysroot", "Path to NDK sysroot (toolchains/llvm/prebuilt/<host>/sysroot)");
    const app_name = required(b, "app_name", "Project's app_name (used as the library basename)");
    const project_root = required(b, "project_root", "Absolute project root (jniLibs install destination is computed from here)");
    const exqlite_src = required(b, "exqlite_src", "Absolute path to deps/exqlite/c_src");

    // Project NIF surface — same shape as the iOS templates. mob_dev's
    // `project_nif_zig_args/1` emits these `-D` flags when there are
    // user-defined NIFs in `mob.exs :static_nifs`. Empty values are
    // valid (project has no NIFs, or this is the armv7 build which
    // currently skips project NIFs — issue #19 scope is arm64 first).
    const project_c_nifs = b.option([]const u8, "project_c_nifs", "Comma-separated C NIF names (each at c_src/<name>.c); empty if none") orelse "";
    const project_rust_libs = b.option([]const u8, "project_rust_libs", "Comma-separated absolute paths to Rust/Zig NIF .a files (pre-built by mob_dev); empty if none") orelse "";
    // Plugin C NIFs — absolute paths to .c files contributed by activated
    // mob plugins (mob_dev gathers these from each plugin's manifest).
    // Basename (sans .c) is the NIF module name, used for the
    // STATIC_ERLANG_NIF_LIBNAME flag below.
    const plugin_c_nifs = b.option([]const u8, "plugin_c_nifs", "Comma-separated absolute paths to plugin C NIF sources; basename = NIF module name; empty if none") orelse "";
    // Plugin zig NIFs — absolute paths to .zig files contributed by activated
    // mob plugins (lang: :zig). Basename (sans .zig) is the NIF module name;
    // the source names its own `export fn <name>_nif_init()` and reaches
    // mob-core bindings via the `erts`/`jni` named imports wired in addZigObject.
    const plugin_zig_nifs = b.option([]const u8, "plugin_zig_nifs", "Comma-separated absolute paths to plugin zig NIF sources; basename = NIF module name; empty if none") orelse "";
    // Plugin JNI-thunk C sources (android.jni_source) — plain C compiled into
    // the app .so so a plugin's Java_<pkg>_<Class>_* thunks resolve. No NIF
    // init libname (these aren't NIFs).
    const plugin_jni_sources = b.option([]const u8, "plugin_jni_sources", "Comma-separated absolute paths to plugin JNI-thunk C sources; empty if none") orelse "";
    // Plugin cpp_archive NIFs: absolute paths to per-ABI lib<mod>.a archives
    // mob_dev cross-compiled (MobDev.Plugin.CppArchive). Each is static-linked
    // like project_rust_libs — its <mod>_nif_init is referenced by driver_tab so
    // the linker pulls it in. The generic replacement for the nxeigen_lib hook.
    const plugin_static_libs = b.option([]const u8, "plugin_static_libs", "Comma-separated absolute paths to plugin cpp_archive .a files (pre-built by mob_dev); empty if none") orelse "";
    // NxEigen (Eigen-backed Nx backend, C++ NIF). mob_dev cross-compiles
    // libnx_eigen.a per arch and threads the per-abi path through nxeigen_lib.
    const nxeigen_static = b.option(bool, "nxeigen_static", "NxEigen NIF statically linked (-DMOB_STATIC_NX_EIGEN_NIF on driver_tab)") orelse false;
    const nxeigen_lib = b.option([]const u8, "nxeigen_lib", "Absolute path to libnx_eigen.a for this ABI (mob_dev sets per arch)") orelse "";
    // TFLite (TensorFlow Lite via nx_tflite_mob). mob_dev cross-compiles a
    // libtflite_nif.a per arch and threads the path through tflite_lib.
    const tflite_static = b.option(bool, "tflite_static", "TFLite NIF statically linked (-DMOB_STATIC_TFLITE_NIF on driver_tab)") orelse false;
    // mob_dev's MobDev.NativeBuild.tflite_zig_args_android/1 emits this
    // alongside -Dtflite_static when TFLite is enabled on Android. Declared
    // as an accepted b.option value so the zig invocation doesn't reject it
    // as unknown. Currently a placeholder for Android TFLite link-side
    // wiring (mirrors the staged-migration pattern the iOS templates use
    // for tflite_dir / tflite_framework_dir).
    const tflite_lib = b.option([]const u8, "tflite_lib", "Absolute path to libtflite_nif.a for this ABI (mob_dev sets per arch when TFLite enabled)") orelse "";
    _ = tflite_lib;

    // Absolute path to `enif_keepalive.c` (generated by
    // `mix mob.deploy --native` for projects that need every enif_*
    // symbol pinned against --gc-sections — Pythonx and any other
    // dlsym-driven NIF dispatch). Empty when mob_dev didn't generate
    // one (vanilla projects with no dynamic NIF surface). Mirrors the
    // iOS template's `-Denif_keepalive=` arg.
    const enif_keepalive = b.option([]const u8, "enif_keepalive", "Absolute path to generated enif_keepalive.c (empty if none needed)") orelse "";

    const target_query = abi_to_target(abi) orelse {
        std.debug.print(
            "ERROR: unsupported -Dabi={s} (expected arm64-v8a, armeabi-v7a, or x86_64)\n",
            .{abi},
        );
        std.process.exit(1);
    };
    const target = b.resolveTargetQuery(target_query);
    const optimize: std.builtin.OptimizeMode = .ReleaseSmall;

    const arch_triple = ndk_arch_triple(abi);
    // Built as a mutable buffer so we can conditionally append static-NIF
    // guard defines (matches the iOS template pattern).
    var c_flags_buf = std.ArrayList([]const u8).empty;
    defer c_flags_buf.deinit(b.allocator);
    const base_c_flags = [_][]const u8{
        "-Os",
        "-ffunction-sections",
        "-fdata-sections",
        "-fPIC",
        "-DSTATIC_ERLANG_NIF",
        b.fmt("--sysroot={s}", .{ndk_sysroot}),
        "-isystem",
        b.fmt("{s}/usr/include", .{ndk_sysroot}),
        "-isystem",
        b.fmt("{s}/usr/include/{s}", .{ ndk_sysroot, arch_triple }),
    };
    for (base_c_flags) |f| c_flags_buf.append(b.allocator, f) catch unreachable;
    if (nxeigen_static) c_flags_buf.append(b.allocator, "-DMOB_STATIC_NX_EIGEN_NIF") catch unreachable;
    const c_flags: []const []const u8 = c_flags_buf.items;

    const c_objects_step = b.step("c-objects", "Compile C objects (no link)");
    const native_lib_step = b.step("native-lib", "Compile + link the per-ABI shared library (default)");
    b.default_step = native_lib_step;

    const sources = [_]CObjectSpec{
        .{ .name = "driver_tab_android", .source = driver_tab },
        // Phase 6b iter 3d (the finale) deleted mob_nif.c — the NIF
        // table, the load callback, and the `mob_nif_nif_init` symbol
        // the driver_tab references all live in mob_nif.zig now.
        .{ .name = "mob_nif", .source = b.fmt("{s}/android/jni/mob_nif.zig", .{mob_dir}) },
        .{ .name = "mob_beam", .source = b.fmt("{s}/android/jni/mob_beam.zig", .{mob_dir}) },
        .{ .name = "beam_jni", .source = b.fmt("{s}/beam_jni.c", .{project_jni_dir}) },
    };

    var obj_paths = std.ArrayList(std.Build.LazyPath).empty;
    defer obj_paths.deinit(b.allocator);

    for (sources) |spec| {
        // Auto-detect .zig vs .c — same pattern as the iOS templates.
        // Zig source declares the C-ABI types it needs via `extern struct`,
        // so it doesn't need the SDK include paths the C path requires.
        // Phase 6b iter 1 wires this up for Android (the iOS templates
        // got the same treatment in 6a iter 2). Iter 2 flipped mob_beam
        // from .c to .zig — the source above ends in .zig, and the helper
        // below threads `build_options` for the comptime flag selection.
        const obj = if (std.mem.endsWith(u8, spec.source, ".zig")) blk: {
            // mob_beam.zig reads `no_beam` and `beam_flags_mode` from
            // @import("build_options"). driver_tab_android.zig reads
            // per-NIF static flags (today: nx_eigen_static; sqlite/emlx
            // are iOS-only). Other .zig sources don't need options.
            const build_opts =
                if (std.mem.eql(u8, spec.name, "mob_beam")) opts: {
                    const o = b.addOptions();
                    o.addOption(bool, "no_beam", false);
                    o.addOption([]const u8, "beam_flags_mode", "nerves_full");
                    break :opts o;
                } else if (std.mem.eql(u8, spec.name, "driver_tab_android")) opts: {
                    const o = b.addOptions();
                    o.addOption(bool, "nx_eigen_static", nxeigen_static);
                    o.addOption(bool, "tflite_static", tflite_static);
                    break :opts o;
                } else null;
            break :blk addZigObject(b, .{
                .name = spec.name,
                .source = spec.source,
                .target = target,
                .optimize = optimize,
                .build_options = build_opts,
            });
        } else addCObject(b, .{
            .name = spec.name,
            .source = spec.source,
            .target = target,
            .optimize = optimize,
            .c_flags = c_flags,
            .otp_dir = otp_dir,
            .erts_vsn = erts_vsn,
            .mob_dir = mob_dir,
        });
        const install = b.addInstallFile(obj, b.fmt("{s}/{s}.o", .{ abi, spec.name }));
        c_objects_step.dependOn(&install.step);
        obj_paths.append(b.allocator, obj) catch @panic("OOM");
    }

    // --- enif_keepalive.c (when present) ──────────────────────────────────────
    // mob_dev writes `android/app/src/main/jni/enif_keepalive.c` and
    // passes `-Denif_keepalive=<path>` when the project ships dynamic
    // NIFs (Pythonx) or static NIFs that resolve the BEAM surface via
    // dlsym at runtime (Rustler 0.37's `nif_filler` looks up
    // `enif_priv_data` etc.). The file references every `enif_*`
    // symbol explicitly so `-Wl,--gc-sections` keeps them in the
    // linked .so. iOS device's build_device.zig takes the same path
    // and makes it required; on Android it's optional so vanilla
    // projects without a dynamic NIF surface don't need a stub file
    // to satisfy the build.
    if (enif_keepalive.len > 0) {
        const obj = addCObject(b, .{
            .name = "enif_keepalive",
            .source = enif_keepalive,
            .target = target,
            .optimize = optimize,
            .c_flags = c_flags,
            .otp_dir = otp_dir,
            .erts_vsn = erts_vsn,
            .mob_dir = mob_dir,
        });
        const install = b.addInstallFile(obj, b.fmt("{s}/enif_keepalive.o", .{abi}));
        c_objects_step.dependOn(&install.step);
        obj_paths.append(b.allocator, obj) catch @panic("OOM");
    }

    // --- Project-side C NIFs (auto-wired from mob.exs :static_nifs) ───────────
    // Mirrors the iOS template (ios/build_device.zig). Each entry name
    // maps to `<project_root>/c_src/<name>.c`. The base `c_flags` already
    // include `-DSTATIC_ERLANG_NIF`, so per-NIF we only need to append
    // `-DSTATIC_ERLANG_NIF_LIBNAME=<name>` — that overrides the
    // ERL_NIF_INIT macro's symbol mangling so the init function is
    // emitted as `<name>_nif_init` (the symbol driver_tab_android
    // declares). Without it the macro tries to mangle the BEAM module
    // name (e.g. `Elixir.App.Nifs.Foo`) into a C identifier, which
    // doesn't compile.
    if (project_c_nifs.len > 0) {
        var c_it = std.mem.splitScalar(u8, project_c_nifs, ',');
        while (c_it.next()) |nif_name| {
            if (nif_name.len == 0) continue;
            const flags = b.allocator.alloc([]const u8, c_flags.len + 1) catch @panic("OOM");
            @memcpy(flags[0..c_flags.len], c_flags);
            flags[c_flags.len] = b.fmt("-DSTATIC_ERLANG_NIF_LIBNAME={s}", .{nif_name});

            const obj = addCObject(b, .{
                .name = nif_name,
                .source = b.fmt("{s}/c_src/{s}.c", .{ project_root, nif_name }),
                .target = target,
                .optimize = optimize,
                .c_flags = flags,
                .otp_dir = otp_dir,
                .erts_vsn = erts_vsn,
                .mob_dir = mob_dir,
            });
            const install = b.addInstallFile(obj, b.fmt("{s}/{s}.o", .{ abi, nif_name }));
            c_objects_step.dependOn(&install.step);
            obj_paths.append(b.allocator, obj) catch @panic("OOM");
        }
    }

    // --- Plugin C NIFs (gathered by mob_dev from activated plugins) ──────────
    // Same shape as project_c_nifs above but with absolute paths (plugins live
    // outside the host's c_src/). Basename (sans .c) is the NIF module name,
    // matching the manifest's nif :module and the symbol the driver table
    // references via STATIC_ERLANG_NIF_LIBNAME.
    if (plugin_c_nifs.len > 0) {
        var p_it = std.mem.splitScalar(u8, plugin_c_nifs, ',');
        while (p_it.next()) |path| {
            if (path.len == 0) continue;
            const basename = std.fs.path.basename(path);
            const name = if (std.mem.endsWith(u8, basename, ".c"))
                basename[0 .. basename.len - 2]
            else
                basename;
            const flags = b.allocator.alloc([]const u8, c_flags.len + 1) catch @panic("OOM");
            @memcpy(flags[0..c_flags.len], c_flags);
            flags[c_flags.len] = b.fmt("-DSTATIC_ERLANG_NIF_LIBNAME={s}", .{name});

            const obj = addCObject(b, .{
                .name = name,
                .source = path,
                .target = target,
                .optimize = optimize,
                .c_flags = flags,
                .otp_dir = otp_dir,
                .erts_vsn = erts_vsn,
                .mob_dir = mob_dir,
            });
            const install = b.addInstallFile(obj, b.fmt("{s}/{s}.o", .{ abi, name }));
            c_objects_step.dependOn(&install.step);
            obj_paths.append(b.allocator, obj) catch @panic("OOM");
        }
    }

    // --- Plugin zig NIFs (gathered by mob_dev from activated plugins) ────────
    // Parallel to plugin_c_nifs but compiled via addZigObject. The plugin
    // .zig names its own `export fn <module>_nif_init()` so it needs no
    // STATIC_ERLANG_NIF_LIBNAME, and reaches mob-core bindings through the
    // `erts`/`jni` named imports addZigObject wires when `mob_dir` is set
    // (the plugin source lives outside mob/android/jni/ so it can't use the
    // sibling-relative @import("mob_erts.zig") that mob_nif.zig itself uses).
    if (plugin_zig_nifs.len > 0) {
        var pz_it = std.mem.splitScalar(u8, plugin_zig_nifs, ',');
        while (pz_it.next()) |path| {
            if (path.len == 0) continue;
            const basename = std.fs.path.basename(path);
            const name = if (std.mem.endsWith(u8, basename, ".zig"))
                basename[0 .. basename.len - 4]
            else
                basename;

            const obj = addZigObject(b, .{
                .name = name,
                .source = path,
                .target = target,
                .optimize = optimize,
                .mob_dir = mob_dir,
            });
            const install = b.addInstallFile(obj, b.fmt("{s}/{s}.o", .{ abi, name }));
            c_objects_step.dependOn(&install.step);
            obj_paths.append(b.allocator, obj) catch @panic("OOM");
        }
    }

    // --- Plugin JNI-thunk C sources (android.jni_source) ─────────────────────
    // Plain C objects (no STATIC_ERLANG_NIF_LIBNAME — these are Java_<pkg>_*
    // JNI thunks, not NIF inits) compiled with the same flags as beam_jni.c so
    // the plugin's nativeDeliver*/nativeRegister thunks resolve in the app .so.
    if (plugin_jni_sources.len > 0) {
        var j_it = std.mem.splitScalar(u8, plugin_jni_sources, ',');
        while (j_it.next()) |path| {
            if (path.len == 0) continue;
            const basename = std.fs.path.basename(path);
            const name = if (std.mem.endsWith(u8, basename, ".c"))
                basename[0 .. basename.len - 2]
            else
                basename;

            const obj = addCObject(b, .{
                .name = name,
                .source = path,
                .target = target,
                .optimize = optimize,
                .c_flags = c_flags,
                .otp_dir = otp_dir,
                .erts_vsn = erts_vsn,
                .mob_dir = mob_dir,
            });
            const install = b.addInstallFile(obj, b.fmt("{s}/{s}.o", .{ abi, name }));
            c_objects_step.dependOn(&install.step);
            obj_paths.append(b.allocator, obj) catch @panic("OOM");
        }
    }

    // Link: zig cc -shared, mirroring CMake's prior target_link_libraries
    // (--gc-sections + --whole-archive bracket around the OTP/crypto static
    // libs + plain libcrypto.a + Android system libs). Returns the cp
    // step that installs the .so into jniLibs/ — exqlite's link depends
    // on it (the file path is a literal arg there, not a LazyPath, so
    // the dependency edge has to be added explicitly).
    const main_link_cp = addLink(b, native_lib_step, .{
        .objects = obj_paths.items,
        .abi = abi,
        .arch_triple = arch_triple,
        .otp_dir = otp_dir,
        .erts_vsn = erts_vsn,
        .ndk_sysroot = ndk_sysroot,
        .app_name = app_name,
        .project_root = project_root,
        .project_rust_libs = project_rust_libs,
        .plugin_static_libs = plugin_static_libs,
        .nxeigen_static = nxeigen_static,
        .nxeigen_lib = nxeigen_lib,
    });

    // --- exqlite / SQLite NIF ─────────────────────────────────────────────
    // Compile sqlite3_nif.c + sqlite3.c (the SQLite amalgamation) and link
    // them into libsqlite3_nif.so. NDK clang for the link as before; zig cc
    // for compile. -DSQLITE_THREADSAFE=1 matches CMake.
    const sqlite_flags = &[_][]const u8{
        "-Os",
        "-ffunction-sections",
        "-fdata-sections",
        "-fPIC",
        "-DSQLITE_THREADSAFE=1",
        b.fmt("--sysroot={s}", .{ndk_sysroot}),
        "-isystem",
        b.fmt("{s}/usr/include", .{ndk_sysroot}),
        "-isystem",
        b.fmt("{s}/usr/include/{s}", .{ ndk_sysroot, arch_triple }),
        "-I",
        exqlite_src,
    };

    const sqlite_sources = [_]CObjectSpec{
        .{ .name = "sqlite3_nif", .source = b.fmt("{s}/sqlite3_nif.c", .{exqlite_src}) },
        .{ .name = "sqlite3", .source = b.fmt("{s}/sqlite3.c", .{exqlite_src}) },
    };

    var sqlite_objs = std.ArrayList(std.Build.LazyPath).empty;
    defer sqlite_objs.deinit(b.allocator);

    for (sqlite_sources) |spec| {
        const obj = addCObject(b, .{
            .name = spec.name,
            .source = spec.source,
            .target = target,
            .optimize = optimize,
            .c_flags = sqlite_flags,
            .otp_dir = otp_dir,
            .erts_vsn = erts_vsn,
            .mob_dir = mob_dir,
        });
        sqlite_objs.append(b.allocator, obj) catch @panic("OOM");
    }

    addExqliteLink(b, native_lib_step, .{
        .objects = sqlite_objs.items,
        .abi = abi,
        .arch_triple = arch_triple,
        .ndk_sysroot = ndk_sysroot,
        .project_root = project_root,
        .app_name = app_name,
        .depends_on = main_link_cp,
    });
}

const CObjectSpec = struct {
    name: []const u8,
    source: []const u8,
};

fn abi_to_target(abi: []const u8) ?std.Target.Query {
    const ver = std.SemanticVersion{ .major = 24, .minor = 0, .patch = 0 };
    if (std.mem.eql(u8, abi, "arm64-v8a")) {
        return .{
            .cpu_arch = .aarch64,
            .os_tag = .linux,
            .os_version_min = .{ .semver = ver },
            .abi = .android,
        };
    }
    if (std.mem.eql(u8, abi, "armeabi-v7a")) {
        return .{
            .cpu_arch = .arm,
            .os_tag = .linux,
            .os_version_min = .{ .semver = ver },
            .abi = .androideabi,
        };
    }
    if (std.mem.eql(u8, abi, "x86_64")) {
        return .{
            .cpu_arch = .x86_64,
            .os_tag = .linux,
            .os_version_min = .{ .semver = ver },
            .abi = .android,
        };
    }
    return null;
}

fn ndk_arch_triple(abi: []const u8) []const u8 {
    if (std.mem.eql(u8, abi, "arm64-v8a")) return "aarch64-linux-android";
    if (std.mem.eql(u8, abi, "armeabi-v7a")) return "arm-linux-androideabi";
    if (std.mem.eql(u8, abi, "x86_64")) return "x86_64-linux-android";
    return "";
}

const CObjectOptions = struct {
    name: []const u8,
    source: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    c_flags: []const []const u8,
    otp_dir: []const u8,
    erts_vsn: []const u8,
    mob_dir: []const u8,
};

fn addCObject(b: *std.Build, opts: CObjectOptions) std.Build.LazyPath {
    const mod = b.createModule(.{
        .target = opts.target,
        .optimize = opts.optimize,
    });
    mod.addCSourceFile(.{
        .file = .{ .cwd_relative = opts.source },
        .flags = opts.c_flags,
    });
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/{s}/include", .{ opts.otp_dir, opts.erts_vsn }),
    });
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/android/jni", .{opts.mob_dir}),
    });

    const obj = b.addObject(.{
        .name = opts.name,
        .root_module = mod,
    });
    return obj.getEmittedBin();
}

const ZigObjectOptions = struct {
    name: []const u8,
    source: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    build_options: ?*std.Build.Step.Options = null,
    // When set, wire the `erts`/`jni` named imports a plugin .zig NIF needs.
    // mob core's own .zig (mob_nif/mob_beam) leaves this null and uses
    // sibling-relative @import instead, since it builds from mob/android/jni/.
    mob_dir: ?[]const u8 = null,
};

// addZigObject compiles a single .zig source file into a relocatable
// object whose exports use the C ABI. The iOS templates use the same
// helper (Phase 6a iters 2-3); this is the Android version. Iter 1
// introduced the helper; iter 2 flipped mob_beam to Zig. mob_nif.c is
// the next candidate (multi-iter — 2570 lines, 79 NIF functions).
fn addZigObject(b: *std.Build, opts: ZigObjectOptions) std.Build.LazyPath {
    const mod = b.createModule(.{
        .root_source_file = .{ .cwd_relative = opts.source },
        .target = opts.target,
        .optimize = opts.optimize,
        // PIC is required because the resulting object is linked into a
        // shared library (lib<app>.so). Without it, .rodata references to
        // local symbols (e.g. mob_beam.zig's `default_flags` array of
        // pointers to string literals) emit R_AARCH64_ABS64 relocations
        // that ld.lld refuses in a shared library. Caught by the Phase 6b
        // iter 3d end-to-end smoke deploy.
        .pic = true,
    });

    if (opts.build_options) |build_opts| {
        mod.addOptions("build_options", build_opts);
    }

    // Plugin .zig NIFs live outside mob/android/jni/, so they can't use the
    // sibling-relative @import("mob_erts.zig") that mob's own .zig uses. When
    // mob_dir is set, wire the `erts` (mob_erts.zig) and `jni` (mob_zig.zig)
    // named modules so the plugin reaches mob-core bindings. Both hand-declare
    // their FFI (no @cImport / OTP headers) and depend only on std.
    if (opts.mob_dir) |md| {
        const erts_mod = b.createModule(.{
            .root_source_file = .{ .cwd_relative = b.fmt("{s}/android/jni/mob_erts.zig", .{md}) },
            .target = opts.target,
            .optimize = opts.optimize,
            .pic = true,
        });
        const jni_mod = b.createModule(.{
            .root_source_file = .{ .cwd_relative = b.fmt("{s}/android/jni/mob_zig.zig", .{md}) },
            .target = opts.target,
            .optimize = opts.optimize,
            .pic = true,
        });
        mod.addImport("erts", erts_mod);
        mod.addImport("jni", jni_mod);
    }

    const obj = b.addObject(.{
        .name = opts.name,
        .root_module = mod,
    });
    return obj.getEmittedBin();
}

const LinkOptions = struct {
    objects: []const std.Build.LazyPath,
    abi: []const u8,
    arch_triple: []const u8,
    otp_dir: []const u8,
    erts_vsn: []const u8,
    ndk_sysroot: []const u8,
    app_name: []const u8,
    project_root: []const u8,
    // Comma-separated absolute paths to per-NIF `.a` archives produced
    // by mob_dev's Rust/Zig cross-compile (`cross_compile_rust_nifs/2`,
    // `cross_compile_zig_nifs/2`). Empty if none.
    project_rust_libs: []const u8 = "",
    // Plugin cpp_archive `.a` archives (comma-separated abs paths). Same link
    // shape as project_rust_libs. Empty if no cpp_archive plugin is active.
    plugin_static_libs: []const u8 = "",
    // NxEigen — set by `mix mob.enable nxeigen`. Empty nxeigen_lib =
    // NxEigen not in this build.
    nxeigen_static: bool = false,
    nxeigen_lib: []const u8 = "",
};

fn addLink(b: *std.Build, step: *std.Build.Step, opts: LinkOptions) *std.Build.Step {
    const so_name = b.fmt("lib{s}.so", .{opts.app_name});

    // Use NDK's clang as the linker driver rather than zig cc — zig's
    // libc-provisioning code rejects Android targets at link time with
    // "unable to provide libc for target". NDK clang knows about the
    // Android ABI / libc / sysroot and just works. zig cc still handles
    // the .o compilation steps above, where it doesn't try to link libc.
    const ndk_clang = b.fmt("{s}/../bin/clang", .{opts.ndk_sysroot});
    const target_arg = b.fmt("--target={s}24", .{opts.arch_triple});

    const run = b.addSystemCommand(&.{ ndk_clang, target_arg, "-shared" });
    run.addArg(b.fmt("--sysroot={s}", .{opts.ndk_sysroot}));
    // Align LOAD segments to 16 KB so the .so works on Android 15+ devices with
    // 16 KB memory pages (Google Play requirement). The prebuilt ERTS lib*.so are
    // already 16 KB-aligned by the OTP NDK build; this covers lib<app>.so.
    run.addArg("-Wl,-z,max-page-size=16384");
    // -Wl,-soname pins the DT_SONAME of the produced .so. Other libs that
    // link against this one (sqlite3_nif via CMake) put the SONAME in their
    // DT_NEEDED list, which is what Android's dlopen looks for at runtime.
    // Without this, sqlite3_nif.so's DT_NEEDED would carry the host build
    // path and dlopen would fail with "library not found".
    run.addArg(b.fmt("-Wl,-soname,{s}", .{so_name}));

    // Object files (compiled in the c-objects step). addFileArg propagates
    // the dependency so each .o is built before this link runs.
    for (opts.objects) |obj| run.addFileArg(obj);

    // Linker flags + OTP static libs in --whole-archive — matches the prior
    // CMake target_link_libraries shape.
    run.addArgs(&.{
        "-Wl,--gc-sections",
        "-Wl,--allow-multiple-definition",
        "-Wl,--whole-archive",
    });

    const whole_archive_libs = [_][]const u8{
        "lib/libbeam.a",
        "lib/internal/liberts_internal_r.a",
        "lib/internal/libethread.a",
        "lib/libzstd.a",
        "lib/libepcre.a",
        "lib/libryu.a",
        "lib/asn1rt_nif.a",
        "lib/crypto.a",
    };
    for (whole_archive_libs) |path| {
        run.addArg(b.fmt("{s}/{s}/{s}", .{ opts.otp_dir, opts.erts_vsn, path }));
    }

    run.addArgs(&.{ "-Wl,--no-whole-archive" });
    run.addArg(b.fmt("{s}/{s}/lib/libcrypto.a", .{ opts.otp_dir, opts.erts_vsn }));

    // Project-side Rust/Zig static NIFs. Each `.a` exports
    // `<name>_nif_init` (rustler 0.37 auto-derives the symbol; Zigler's
    // fork honours `-Dnif_init_alias=<name>_nif_init`). The static-NIF
    // table in driver_tab_android.{zig,c} declares + references that
    // symbol, so the linker pulls each archive into the final .so even
    // outside the --whole-archive bracket (the table reference is a
    // strong undefined). Mirrors the iOS link path.
    if (opts.project_rust_libs.len > 0) {
        var it = std.mem.splitScalar(u8, opts.project_rust_libs, ',');
        while (it.next()) |a_path| {
            if (a_path.len == 0) continue;
            // `addFileArg` (not `addArg`) so the cache key picks up the
            // contents of the .a, not just its path. Otherwise the link
            // step is reported UP-TO-DATE after rebuilding a project-side
            // rust crate — the new .a sits unused in jniLibs.
            const lp: std.Build.LazyPath = .{ .cwd_relative = a_path };
            run.addFileArg(lp);
        }
    }

    // Plugin cpp_archive NIFs (e.g. an Nx CPU backend). Each lib<mod>.a
    // exports <mod>_nif_init, referenced by driver_tab_android, so the linker
    // pulls it in via the strong undefined — same mechanism as project_rust_libs.
    // addFileArg so the cache key tracks archive contents, not just the path.
    if (opts.plugin_static_libs.len > 0) {
        var ps_it = std.mem.splitScalar(u8, opts.plugin_static_libs, ',');
        while (ps_it.next()) |a_path| {
            if (a_path.len == 0) continue;
            const lp: std.Build.LazyPath = .{ .cwd_relative = a_path };
            run.addFileArg(lp);
        }
    }

    // NxEigen (Eigen-backed Nx backend, C++ NIF). nx_eigen_nif_init is
    // referenced from driver_tab_android, so the linker pulls libnx_eigen.a
    // in via the strong undefined reference — same mechanism as the Rust
    // NIF archives above. Use addFileArg so cache invalidation tracks the
    // archive contents.
    if (opts.nxeigen_static and opts.nxeigen_lib.len > 0) {
        const lp: std.Build.LazyPath = .{ .cwd_relative = opts.nxeigen_lib };
        run.addFileArg(lp);
    }

    // Android system libs. -lc++_static + -lc++abi mirrors CMake's prior
    // setup (NDK 27 split __cxa_* / RTTI ABI symbols out of libc++_static
    // into libc++abi). -static-libstdc++ alone leaves typeinfo symbols
    // unresolved at runtime — `dlopen` fails with "cannot locate symbol
    // '_ZTISt12length_error'".
    run.addArgs(&.{
        "-landroid",
        "-llog",
        "-lz",
        "-lc++_static",
        "-lc++abi",
        "-lm",
    });

    run.addArg("-o");
    const so_lp = run.addOutputFileArg(so_name);

    // Install the .so to jniLibs/<abi>/ where Gradle's default scan picks
    // it up. Bypasses --prefix because we want jniLibs/, not zig-out/.
    const install_path = b.fmt(
        "{s}/android/app/src/main/jniLibs/{s}/{s}",
        .{ opts.project_root, opts.abi, so_name },
    );
    const cp = b.addSystemCommand(&.{"cp"});
    cp.addFileArg(so_lp);
    cp.addArg(install_path);
    cp.step.dependOn(&run.step);
    step.dependOn(&cp.step);
    // Return the cp step so addExqliteLink can `dependOn` it — exqlite's
    // link references the installed main .so via a literal path arg, not
    // a LazyPath, so without an explicit ordering edge the two link steps
    // race in parallel and exqlite's clang errors out with "no such file"
    // when the cp hasn't run yet. Caught by the Phase 6b iter 3d smoke
    // deploy.
    return &cp.step;
}

const ExqliteLinkOptions = struct {
    objects: []const std.Build.LazyPath,
    abi: []const u8,
    arch_triple: []const u8,
    ndk_sysroot: []const u8,
    project_root: []const u8,
    app_name: []const u8,
    // Step that must complete before this link runs — typically the cp
    // step returned by `addLink` (which installs lib<app>.so into
    // jniLibs/, the path exqlite's link consumes by string).
    depends_on: ?*std.Build.Step = null,
};

fn addExqliteLink(b: *std.Build, step: *std.Build.Step, opts: ExqliteLinkOptions) void {
    // sqlite3_nif's NIF entry points (enif_*) come from lib<app>.so at
    // runtime. We link against it here so the produced .so has a
    // DT_NEEDED entry pointing at lib<app>.so's SONAME — Android's
    // loader then ensures lib<app>.so is mapped first and the enif_*
    // symbols resolve.
    const ndk_clang = b.fmt("{s}/../bin/clang", .{opts.ndk_sysroot});
    const target_arg = b.fmt("--target={s}24", .{opts.arch_triple});
    const so_name = "libsqlite3_nif.so";
    const app_so = b.fmt(
        "{s}/android/app/src/main/jniLibs/{s}/lib{s}.so",
        .{ opts.project_root, opts.abi, opts.app_name },
    );

    const run = b.addSystemCommand(&.{ ndk_clang, target_arg, "-shared" });
    if (opts.depends_on) |dep| run.step.dependOn(dep);
    run.addArg(b.fmt("--sysroot={s}", .{opts.ndk_sysroot}));
    // 16 KB page alignment (Android 15+ / Google Play requirement), as for lib<app>.so.
    run.addArg("-Wl,-z,max-page-size=16384");
    run.addArg(b.fmt("-Wl,-soname,{s}", .{so_name}));
    for (opts.objects) |obj| run.addFileArg(obj);
    // The main .so provides enif_* (and Android system libs cover the rest).
    run.addArg(app_so);
    run.addArgs(&.{ "-landroid", "-llog", "-lm" });

    run.addArg("-o");
    const so_lp = run.addOutputFileArg(so_name);

    const install_path = b.fmt(
        "{s}/android/app/src/main/jniLibs/{s}/{s}",
        .{ opts.project_root, opts.abi, so_name },
    );
    const cp = b.addSystemCommand(&.{"cp"});
    cp.addFileArg(so_lp);
    cp.addArg(install_path);
    cp.step.dependOn(&run.step);
    step.dependOn(&cp.step);
}

fn required(b: *std.Build, name: []const u8, desc: []const u8) []const u8 {
    return b.option([]const u8, name, desc) orelse {
        std.debug.print(
            "ERROR: -D{s}=... is required ({s})\n",
            .{ name, desc },
        );
        std.process.exit(1);
    };
}
