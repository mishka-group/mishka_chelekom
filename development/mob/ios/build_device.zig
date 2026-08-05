// build_device.zig — Native build orchestration for MishkaMob (iOS device).
//
// Phase 2 iter 12 of the build-system migration. Sister to ios/build.zig
// (which targets iOS sim). Handles the seven standard native sources for
// the iphoneos build:
//
//   Plain C (zig cc):
//     - driver_tab_ios.zig (or .c — extension auto-detected at compile)
//     - enif_keepalive.c
//
//   ObjC (xcrun cc via system command — Apple's clang for -fmodules):
//     - $MOB_DIR/ios/MobNode.m
//     - $MOB_DIR/ios/mob_nif.m       (-DSTATIC_ERLANG_NIF + swift hdr)
//     - $MOB_DIR/ios/mob_beam.m      (-DMOB_BUNDLE_OTP, -DERTS_VSN, -DOTP_RELEASE)
//     - ios/AppDelegate.m            (in-project, swift hdr)
//     - ios/beam_main.m              (in-project)
//
//   Swift (xcrun swiftc via system command):
//     - $MOB_DIR/ios/MobViewModel.swift
//     - $MOB_DIR/ios/MobRootView.swift
//     - optional project Swift sources from -Dproject_swift_sources
//
// Differences vs build.zig (iOS sim):
//   - SDK: iphoneos vs iphonesimulator
//   - Target: arm64-apple-ios17.0 vs aarch64-ios-simulator
//   - mob_beam.m needs -DMOB_BUNDLE_OTP + ERTS_VSN/OTP_RELEASE strings
//
// EPMD compile, erl_errno_id_compat stub, the link, bundle, codesign,
// and devicectl install all stay in build_device.sh for this iter — they
// move into Mix as iter 12b/c.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .ios,
    });
    const optimize: std.builtin.OptimizeMode = .ReleaseSmall;

    const mob_dir = required(b, "mob_dir", "Path to mob library");
    const otp_root = required(b, "otp_root", "Path to iOS OTP runtime");
    const erts_vsn = required(b, "erts_vsn", "ERTS version dir name (e.g. erts-17.0)");
    const otp_release = required(b, "otp_release", "OTP release number (e.g. 29)");
    const sdkroot = required(b, "sdkroot", "iOS device SDK path");
    const driver_tab = required(b, "driver_tab", "Absolute path to driver_tab_ios.{zig,c}");
    const enif_keepalive = required(b, "enif_keepalive", "Absolute path to generated enif_keepalive.c");
    const project_ios_dir = required(b, "project_ios_dir", "Absolute path to project's ios/ dir");
    const module_name = required(b, "module_name", "Swift module name (display_name)");
    const sqlite_static = b.option(bool, "sqlite_static", "exqlite NIF is statically linked (-DMOB_STATIC_SQLITE_NIF on driver_tab)") orelse false;
    const epmd_build_src = required(b, "epmd_build_src", "OTP tree exposing erts/epmd/src + erts/include (the iOS-device OTP cache by default)");
    const errno_compat = required(b, "errno_compat", "Absolute path to the generated erl_errno_id_compat.c shim");
    const sqlite_static_lib = b.option([]const u8, "sqlite_static_lib", "Absolute path to sqlite3_nif.a (when exqlite is statically linked)") orelse "";
    // MLX + EMLX (Apple's MLX numerics + the EMLX Nx backend). Enabled by
    // `mix mob.enable mlx`. mob_dev fetches a pre-cross-compiled bundle via
    // MobDev.MLXDownloader and passes its root here.
    const mlx_static = b.option(bool, "mlx_static", "EMLX NIF statically linked + libmlx.a included (-DMOB_STATIC_EMLX_NIF on driver_tab)") orelse false;
    const mlx_dir = b.option([]const u8, "mlx_dir", "Absolute path to extracted MLX bundle (libmlx.a + libemlx.a + include/)") orelse "";
    // NxEigen (Eigen-backed Nx backend, C++ NIF). mob_dev cross-compiles
    // libnx_eigen.a per arch and threads the output dir through nxeigen_dir.
    const nxeigen_static = b.option(bool, "nxeigen_static", "NxEigen NIF statically linked (-DMOB_STATIC_NX_EIGEN_NIF on driver_tab)") orelse false;
    const nxeigen_dir = b.option([]const u8, "nxeigen_dir", "Absolute path to dir containing libnx_eigen.a") orelse "";
    // TFLite (TensorFlow Lite via nx_tflite_mob). mob_dev cross-compiles
    // libtflite_nif.a per arch and threads the path through tflite_dir; the
    // TensorFlowLiteC.framework comes via tflite_framework_dir. The static
    // flag flips the comptime gate in driver_tab_ios.zig — without it the
    // generated driver_tab (which always references build_options.tflite_static
    // because MobDev.StaticNifs.default_nifs/0 includes :tflite_nif on :all)
    // fails to compile with "struct 'options' has no member named 'tflite_static'".
    const tflite_static = b.option(bool, "tflite_static", "TFLite NIF statically linked (-DMOB_STATIC_TFLITE_NIF on driver_tab)") orelse false;
    // mob_dev's MobDev.NativeBuild.tflite_zig_args_ios/1 emits these
    // alongside -Dtflite_static. Declared as accepted b.option values so
    // the zig invocation doesn't reject them as unknown. Currently a
    // placeholder for iOS TFLite link-side wiring (mirrors how the Android
    // template declares tflite_static without yet using a per-arch tflite_lib).
    const tflite_dir = b.option([]const u8, "tflite_dir", "Absolute path to dir containing libtflite_nif.a (iOS, when TFLite enabled)") orelse "";
    const tflite_framework_dir = b.option([]const u8, "tflite_framework_dir", "Absolute path to TensorFlowLiteC.framework Frameworks/ dir (iOS, when TFLite enabled)") orelse "";
    _ = tflite_dir;
    _ = tflite_framework_dir;
    // Project-side NIFs declared in `mob.exs :static_nifs` (see issue #18).
    // mob_dev passes these comma-separated lists after resolving each entry
    // against `c_src/<name>.c` and `native/<name>/Cargo.toml`. Empty by
    // default — old projects without project-side NIFs are unaffected.
    const project_root = b.option([]const u8, "project_root", "Absolute path to the project root (for c_src/<name>.c lookups)") orelse "";
    const project_c_nifs = b.option([]const u8, "project_c_nifs", "Comma-separated C NIF names (each at c_src/<name>.c); empty if none") orelse "";
    const project_rust_libs = b.option([]const u8, "project_rust_libs", "Comma-separated absolute paths to Rust NIF .a files (pre-built by mob_dev)") orelse "";
    const project_swift_sources = b.option([]const u8, "project_swift_sources", "Comma-separated absolute paths to extra project Swift sources; empty if none") orelse "";
    // Plugin contributions gathered by mob_dev from activated plugin manifests
    // (same shape as the sim build).
    const plugin_swift_files = b.option([]const u8, "plugin_swift_files", "Comma-separated absolute paths to plugin Swift sources; empty if none") orelse "";
    const plugin_frameworks = b.option([]const u8, "plugin_frameworks", "Comma-separated iOS framework names contributed by plugins; empty if none") orelse "";
    const plugin_c_nifs = b.option([]const u8, "plugin_c_nifs", "Comma-separated absolute paths to plugin C NIF sources; basename = NIF module name; empty if none") orelse "";
    const plugin_static_libs = b.option([]const u8, "plugin_static_libs", "Comma-separated absolute paths to plugin cpp_archive .a files (pre-built by mob_dev); empty if none") orelse "";

    const objects_step = b.step("objects", "Compile C, ObjC, and Swift objects for iOS device");
    const binary_step = b.step("binary", "Compile + link the iOS device binary (default)");
    b.default_step = binary_step;

    // Collect every produced .o LazyPath so the link step can consume them.
    var objs = std.ArrayList(std.Build.LazyPath).empty;
    defer objs.deinit(b.allocator);

    // --- Swift via xcrun swiftc ------------------------------------------------
    const swift_run = b.addSystemCommand(&.{
        "xcrun",
        "-sdk",
        "iphoneos",
        "swiftc",
        "-target",
        "arm64-apple-ios17.0",
        "-module-name",
        module_name,
        "-import-objc-header",
    });
    swift_run.addArg(b.fmt("{s}/ios/MobDemo-Bridging-Header.h", .{mob_dir}));
    swift_run.addArg("-I");
    swift_run.addArg(b.fmt("{s}/ios", .{mob_dir}));
    swift_run.addArgs(&.{ "-parse-as-library", "-wmo" });
    // Glob all mob Swift sources so a newly-added file (e.g. MobGpuView.swift,
    // referenced by MobRootView) compiles without editing this template.
    {
        const glob_io = b.graph.io;
        var mob_ios = b.build_root.handle.openDir(glob_io, b.fmt("{s}/ios", .{mob_dir}), .{ .iterate = true }) catch @panic("mob ios dir not found");
        defer mob_ios.close(glob_io);
        var swift_entries = mob_ios.iterate();
        while (swift_entries.next(glob_io) catch @panic("mob ios dir iterate failed")) |entry| {
            if (entry.kind == .file and std.mem.endsWith(u8, entry.name, ".swift")) {
                swift_run.addFileArg(.{ .cwd_relative = b.fmt("{s}/ios/{s}", .{ mob_dir, entry.name }) });
            }
        }
    }
    if (project_swift_sources.len > 0) {
        var swift_it = std.mem.splitScalar(u8, project_swift_sources, ',');
        while (swift_it.next()) |source| {
            if (source.len == 0) continue;
            swift_run.addFileArg(.{ .cwd_relative = source });
        }
    }
    // Plugin-contributed Swift sources compile in the same step so the
    // -emit-objc-header pass sees everything that needs to bridge to ObjC.
    if (plugin_swift_files.len > 0) {
        var plugin_swift_it = std.mem.splitScalar(u8, plugin_swift_files, ',');
        while (plugin_swift_it.next()) |source| {
            if (source.len == 0) continue;
            swift_run.addFileArg(.{ .cwd_relative = source });
        }
    }
    swift_run.addArg("-c");
    swift_run.addArg("-emit-objc-header");
    swift_run.addArg("-emit-objc-header-path");
    const swift_header = swift_run.addOutputFileArg("MobApp-Swift.h");
    swift_run.addArg("-o");
    const swift_obj = swift_run.addOutputFileArg("swift_mob.o");
    installAndCollect(b, objects_step, &objs, swift_obj, "swift_mob.o");

    // --- Plain C via zig cc ----------------------------------------------------
    const c_flags_base = &[_][]const u8{
        "-Os",
        "-ffunction-sections",
        "-fdata-sections",
        "-miphoneos-version-min=17.0",
    };

    // Build the C-path driver_tab compile flags, appending one -D<guard> per
    // enabled NIF. The Zig-path driver_tab gets the same set via
    // b.addOptions() below.
    var driver_tab_flags_buf = std.ArrayList([]const u8).empty;
    defer driver_tab_flags_buf.deinit(b.allocator);
    for (c_flags_base) |f| driver_tab_flags_buf.append(b.allocator, f) catch unreachable;
    if (sqlite_static) driver_tab_flags_buf.append(b.allocator, "-DMOB_STATIC_SQLITE_NIF") catch unreachable;
    if (mlx_static) driver_tab_flags_buf.append(b.allocator, "-DMOB_STATIC_EMLX_NIF") catch unreachable;
    if (nxeigen_static) driver_tab_flags_buf.append(b.allocator, "-DMOB_STATIC_NX_EIGEN_NIF") catch unreachable;
    if (tflite_static) driver_tab_flags_buf.append(b.allocator, "-DMOB_STATIC_TFLITE_NIF") catch unreachable;
    const driver_tab_flags: []const []const u8 = driver_tab_flags_buf.items;

    // Auto-detect .zig vs .c on driver_tab. The .zig path threads
    // sqlite_static via b.addOptions() — a comptime `if (sqlite_static)`
    // inside the .zig file replaces the C preprocessor `#ifdef
    // MOB_STATIC_SQLITE_NIF`. The .c path keeps the legacy
    // -DMOB_STATIC_SQLITE_NIF flag through driver_tab_flags.
    const driver_tab_lp = if (std.mem.endsWith(u8, driver_tab, ".zig")) blk: {
        const opts = b.addOptions();
        opts.addOption(bool, "sqlite_static", sqlite_static);
        opts.addOption(bool, "emlx_static", mlx_static);
        opts.addOption(bool, "nx_eigen_static", nxeigen_static);
        opts.addOption(bool, "tflite_static", tflite_static);
        break :blk addZigObject(b, .{
            .name = "driver_tab_ios",
            .source = driver_tab,
            .target = target,
            .optimize = optimize,
            .build_options = opts,
        });
    } else addCObject(b, .{
        .name = "driver_tab_ios",
        .source = driver_tab,
        .target = target,
        .optimize = optimize,
        .c_flags = driver_tab_flags,
        .mob_dir = mob_dir,
        .otp_root = otp_root,
        .erts_vsn = erts_vsn,
        .sdkroot = sdkroot,
    });
    installAndCollect(b, objects_step, &objs, driver_tab_lp, "driver_tab_ios.o");

    installAndCollect(b, objects_step, &objs, addCObject(b, .{
        .name = "enif_keepalive",
        .source = enif_keepalive,
        .target = target,
        .optimize = optimize,
        .c_flags = c_flags_base,
        .mob_dir = mob_dir,
        .otp_root = otp_root,
        .erts_vsn = erts_vsn,
        .sdkroot = sdkroot,
    }), "enif_keepalive.o");

    // --- ObjC via xcrun cc -----------------------------------------------------
    const mob_beam_flags = &[_][]const u8{
        "-DMOB_BUNDLE_OTP",
        b.fmt("-DERTS_VSN=\"{s}\"", .{erts_vsn}),
        b.fmt("-DOTP_RELEASE=\"{s}\"", .{otp_release}),
    };

    const objc_specs = [_]ObjcSpec{
        .{ .name = "MobNode", .source = b.fmt("{s}/ios/MobNode.m", .{mob_dir}) },
        .{
            .name = "mob_nif",
            .source = b.fmt("{s}/ios/mob_nif.m", .{mob_dir}),
            .extra_flags = &.{"-DSTATIC_ERLANG_NIF"},
            .swift_header = swift_header,
        },
        .{
            .name = "mob_beam",
            .source = b.fmt("{s}/ios/mob_beam.m", .{mob_dir}),
            .extra_flags = mob_beam_flags,
        },
        .{
            .name = "AppDelegate",
            .source = b.fmt("{s}/AppDelegate.m", .{project_ios_dir}),
            .swift_header = swift_header,
        },
        .{ .name = "beam_main", .source = b.fmt("{s}/beam_main.m", .{project_ios_dir}) },
    };

    for (objc_specs) |spec| {
        installAndCollect(b, objects_step, &objs, addObjcObject(b, .{
            .name = spec.name,
            .source = spec.source,
            .extra_flags = spec.extra_flags,
            .swift_header = spec.swift_header,
            .mob_dir = mob_dir,
            .otp_root = otp_root,
            .erts_vsn = erts_vsn,
            .sdkroot = sdkroot,
        }), b.fmt("{s}.o", .{spec.name}));
    }

    // --- EPMD (in-process, NO_DAEMON) ──────────────────────────────────────────
    // EPMD's main() is renamed to epmd_ios_main() and run on a background
    // thread inside the BEAM. -DNO_DAEMON elides the run_daemon() body so
    // fork() never gets pulled into the link (iOS sandbox would deny it).
    // The epmd.c source is patched separately (idempotent inline edit in
    // build_device.sh) to wrap the run_daemon call site in #ifndef NO_DAEMON
    // — pre-Phase-2 OTP tarballs ship without that guard.
    const epmd_src = b.fmt("{s}/erts/epmd/src", .{epmd_build_src});
    const epmd_flags = &[_][]const u8{
        "-DHAVE_CONFIG_H",
        "-DEPMD_PORT_NO=4369",
        "-Dmain=epmd_ios_main",
        "-DNO_DAEMON",
        "-Os",
        "-ffunction-sections",
        "-fdata-sections",
        "-miphoneos-version-min=17.0",
    };

    const epmd_specs = [_]CObjectSpec{
        .{ .name = "epmd_main", .source = b.fmt("{s}/epmd.c", .{epmd_src}) },
        .{ .name = "epmd_srv", .source = b.fmt("{s}/epmd_srv.c", .{epmd_src}) },
        .{ .name = "epmd_cli", .source = b.fmt("{s}/epmd_cli.c", .{epmd_src}) },
    };

    for (epmd_specs) |spec| {
        installAndCollect(b, objects_step, &objs, addEpmdObject(b, .{
            .name = spec.name,
            .source = spec.source,
            .target = target,
            .optimize = optimize,
            .c_flags = epmd_flags,
            .epmd_build_src = epmd_build_src,
            .epmd_src = epmd_src,
            .sdkroot = sdkroot,
        }), b.fmt("{s}.o", .{spec.name}));
    }

    // --- erl_errno_id_compat ──────────────────────────────────────────────────
    // Weak shim for erl_errno_id_unknown. The iOS-device OTP tarball
    // includes the legacy erl_posix_str.o (sim/Android tarballs don't),
    // which the linker pulls in to satisfy _erl_errno_id and which leaves
    // _erl_errno_id_unknown undefined. The weak shim resolves it; if a
    // future tarball drops erl_posix_str.o this becomes dead code (loses
    // to the real symbol). See native_build.ex's
    // generate_erl_errno_compat_stub/1 for the full diagnosis.
    installAndCollect(b, objects_step, &objs, addCObject(b, .{
        .name = "erl_errno_id_compat",
        .source = errno_compat,
        .target = target,
        .optimize = optimize,
        .c_flags = c_flags_base,
        .mob_dir = mob_dir,
        .otp_root = otp_root,
        .erts_vsn = erts_vsn,
        .sdkroot = sdkroot,
    }), "erl_errno_id_compat.o");

    // --- Project-side C NIFs (auto-wired from mob.exs :static_nifs) ───────────
    // Each entry name maps to `c_src/<name>.c`. mob_dev passes the
    // comma-separated list of names, plus the project root path for
    // resolving the sources. -DSTATIC_ERLANG_NIF selects the static-link
    // dispatch path in erl_nif.h; -DSTATIC_ERLANG_NIF_LIBNAME=<name>
    // overrides the init function's symbol name to `<name>_nif_init`
    // (matching driver_tab's declaration). Without the latter, the
    // macro tries to mangle the BEAM module name (e.g.
    // `Elixir.App.Nifs.Foo`) into a C identifier, which doesn't compile.
    if (project_c_nifs.len > 0) {
        var c_it = std.mem.splitScalar(u8, project_c_nifs, ',');
        while (c_it.next()) |nif_name| {
            if (nif_name.len == 0) continue;
            const flags = b.allocator.alloc([]const u8, c_flags_base.len + 2) catch unreachable;
            @memcpy(flags[0..c_flags_base.len], c_flags_base);
            flags[c_flags_base.len] = "-DSTATIC_ERLANG_NIF";
            flags[c_flags_base.len + 1] = b.fmt("-DSTATIC_ERLANG_NIF_LIBNAME={s}", .{nif_name});

            installAndCollect(b, objects_step, &objs, addCObject(b, .{
                .name = nif_name,
                .source = b.fmt("{s}/c_src/{s}.c", .{ project_root, nif_name }),
                .target = target,
                .optimize = optimize,
                .c_flags = flags,
                .mob_dir = mob_dir,
                .otp_root = otp_root,
                .erts_vsn = erts_vsn,
                .sdkroot = sdkroot,
            }), b.fmt("{s}.o", .{nif_name}));
        }
    }

    // --- Plugin-side C NIFs (tier-1 plugins; absolute paths from mob_dev) ─────
    // Mirrors the project_c_nifs block above + the Android plugin_c_nifs path.
    // basename minus ".c" = NIF module name = STATIC_ERLANG_NIF_LIBNAME, which
    // must match the <module>_nif_init symbol driver_tab_ios references.
    if (plugin_c_nifs.len > 0) {
        var p_it = std.mem.splitScalar(u8, plugin_c_nifs, ',');
        while (p_it.next()) |path| {
            if (path.len == 0) continue;
            const base = std.fs.path.basename(path);
            // .m sources (manifest lang: :objc) are Objective-C — an iOS plugin
            // NIF driving an Apple framework (CoreLocation, etc.). Compiled as
            // ObjC by extension; add -fobjc-arc + -fmodules. ".c"/".m" are both 2.
            const is_objc = std.mem.endsWith(u8, base, ".m");
            const name = if (std.mem.endsWith(u8, base, ".c") or is_objc) base[0 .. base.len - 2] else base;

            if (is_objc) {
                // ObjC plugin NIFs that import heavy framework modules (UIKit,
                // Accelerate/vImage — e.g. mob_camera) must be built by Apple's
                // clang via xcrun, NOT zig's bundled clang: zig clang fails to
                // build those system framework modules against current Xcode SDKs
                // ("umbrella header for module 'Accelerate.vecLib' does not include
                // 'lapack.h'", UIKit missing 'UIUtilities/UIDefines.h'). This is
                // exactly why core's own mob_nif.m goes through addObjcObject. The
                // STATIC_ERLANG_NIF defines ride along as extra_flags.
                installAndCollect(b, objects_step, &objs, addObjcObject(b, .{
                    .name = name,
                    .source = path,
                    .extra_flags = &.{
                        "-DSTATIC_ERLANG_NIF",
                        b.fmt("-DSTATIC_ERLANG_NIF_LIBNAME={s}", .{name}),
                    },
                    .mob_dir = mob_dir,
                    .otp_root = otp_root,
                    .erts_vsn = erts_vsn,
                    .sdkroot = sdkroot,
                }), b.fmt("{s}.o", .{name}));
                continue;
            }

            const flags = b.allocator.alloc([]const u8, c_flags_base.len + 2) catch unreachable;
            @memcpy(flags[0..c_flags_base.len], c_flags_base);
            flags[c_flags_base.len] = "-DSTATIC_ERLANG_NIF";
            flags[c_flags_base.len + 1] = b.fmt("-DSTATIC_ERLANG_NIF_LIBNAME={s}", .{name});

            installAndCollect(b, objects_step, &objs, addCObject(b, .{
                .name = name,
                .source = path,
                .target = target,
                .optimize = optimize,
                .c_flags = flags,
                .mob_dir = mob_dir,
                .otp_root = otp_root,
                .erts_vsn = erts_vsn,
                .sdkroot = sdkroot,
            }), b.fmt("{s}.o", .{name}));
        }
    }

    // --- Link via xcrun swiftc -------------------------------------------------
    addLink(b, binary_step, .{
        .module_name = module_name,
        .otp_root = otp_root,
        .erts_vsn = erts_vsn,
        .sqlite_static_lib = sqlite_static_lib,
        .mlx_static = mlx_static,
        .mlx_dir = mlx_dir,
        .nxeigen_static = nxeigen_static,
        .nxeigen_dir = nxeigen_dir,
        .project_rust_libs = project_rust_libs,
        .plugin_static_libs = plugin_static_libs,
        .plugin_frameworks = plugin_frameworks,
        .objects = objs.items,
    });
}

const CObjectSpec = struct {
    name: []const u8,
    source: []const u8,
};

const ObjcSpec = struct {
    name: []const u8,
    source: []const u8,
    extra_flags: []const []const u8 = &.{},
    swift_header: ?std.Build.LazyPath = null,
};

const CObjectOptions = struct {
    name: []const u8,
    source: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    c_flags: []const []const u8,
    mob_dir: []const u8,
    otp_root: []const u8,
    erts_vsn: []const u8,
    sdkroot: []const u8,
};

const ZigObjectOptions = struct {
    name: []const u8,
    source: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    // build_options is imported by the .zig module via
    // `@import("build_options")`. driver_tab_ios.zig uses it to read
    // `sqlite_static` so the comptime gate around the guarded NIF row
    // fires correctly. nil means "no build_options module needed."
    build_options: ?*std.Build.Step.Options = null,
};

// addZigObject compiles a single .zig source file into a relocatable
// object whose exports use the C ABI. Used by Phase 6a's driver_tab.zig
// path; matches addCObject's interface so the call site can pick one or
// the other based on the source file's extension.
fn addZigObject(b: *std.Build, opts: ZigObjectOptions) std.Build.LazyPath {
    const mod = b.createModule(.{
        .root_source_file = .{ .cwd_relative = opts.source },
        .target = opts.target,
        .optimize = opts.optimize,
    });

    if (opts.build_options) |build_opts| {
        mod.addOptions("build_options", build_opts);
    }

    const obj = b.addObject(.{
        .name = opts.name,
        .root_module = mod,
    });
    return obj.getEmittedBin();
}

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
        .cwd_relative = b.fmt("{s}/{s}/include", .{ opts.otp_root, opts.erts_vsn }),
    });
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/{s}/include/internal", .{ opts.otp_root, opts.erts_vsn }),
    });
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/ios", .{opts.mob_dir}),
    });
    mod.addSystemIncludePath(.{
        .cwd_relative = b.fmt("{s}/usr/include", .{opts.sdkroot}),
    });
    mod.addFrameworkPath(.{
        .cwd_relative = b.fmt("{s}/System/Library/Frameworks", .{opts.sdkroot}),
    });

    const obj = b.addObject(.{
        .name = opts.name,
        .root_module = mod,
    });
    return obj.getEmittedBin();
}

const ObjcObjectOptions = struct {
    name: []const u8,
    source: []const u8,
    extra_flags: []const []const u8 = &.{},
    swift_header: ?std.Build.LazyPath = null,
    mob_dir: []const u8,
    otp_root: []const u8,
    erts_vsn: []const u8,
    sdkroot: []const u8,
};

fn addObjcObject(b: *std.Build, opts: ObjcObjectOptions) std.Build.LazyPath {
    const run = b.addSystemCommand(&.{
        "xcrun",
        "-sdk",
        "iphoneos",
        "cc",
        "-arch",
        "arm64",
        "-miphoneos-version-min=17.0",
        "-Os",
        "-ffunction-sections",
        "-fdata-sections",
        "-fobjc-arc",
        "-fmodules",
    });
    run.addArg(b.fmt("-I{s}/{s}/include", .{ opts.otp_root, opts.erts_vsn }));
    run.addArg(b.fmt("-I{s}/{s}/include/internal", .{ opts.otp_root, opts.erts_vsn }));
    run.addArg(b.fmt("-I{s}/ios", .{opts.mob_dir}));
    run.addArg(b.fmt("-isysroot{s}", .{opts.sdkroot}));

    if (opts.swift_header) |sh| {
        run.addPrefixedDirectoryArg("-I", sh.dirname());
    }

    for (opts.extra_flags) |flag| run.addArg(flag);
    run.addArg("-c");
    run.addFileArg(.{ .cwd_relative = opts.source });
    run.addArg("-o");
    return run.addOutputFileArg(b.fmt("{s}.o", .{opts.name}));
}

const EpmdObjectOptions = struct {
    name: []const u8,
    source: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    c_flags: []const []const u8,
    epmd_build_src: []const u8,
    epmd_src: []const u8,
    sdkroot: []const u8,
};

fn addEpmdObject(b: *std.Build, opts: EpmdObjectOptions) std.Build.LazyPath {
    const mod = b.createModule(.{
        .target = opts.target,
        .optimize = opts.optimize,
    });
    mod.addCSourceFile(.{
        .file = .{ .cwd_relative = opts.source },
        .flags = opts.c_flags,
    });
    // EPMD's includes are scattered across the OTP tree:
    //   erts/aarch64-apple-ios/   architecture-specific config.h etc.
    //   erts/epmd/src/             epmd's own headers
    //   erts/include/              public BEAM headers
    //   erts/include/internal/     internal BEAM headers
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/erts/aarch64-apple-ios", .{opts.epmd_build_src}),
    });
    mod.addIncludePath(.{ .cwd_relative = opts.epmd_src });
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/erts/include", .{opts.epmd_build_src}),
    });
    mod.addIncludePath(.{
        .cwd_relative = b.fmt("{s}/erts/include/internal", .{opts.epmd_build_src}),
    });
    mod.addSystemIncludePath(.{
        .cwd_relative = b.fmt("{s}/usr/include", .{opts.sdkroot}),
    });

    const obj = b.addObject(.{
        .name = opts.name,
        .root_module = mod,
    });
    return obj.getEmittedBin();
}

fn installAndCollect(
    b: *std.Build,
    step: *std.Build.Step,
    objs: *std.ArrayList(std.Build.LazyPath),
    lp: std.Build.LazyPath,
    install_name: []const u8,
) void {
    const install = b.addInstallFile(lp, install_name);
    step.dependOn(&install.step);
    objs.append(b.allocator, lp) catch @panic("OOM");
}

const LinkOptions = struct {
    module_name: []const u8,
    otp_root: []const u8,
    erts_vsn: []const u8,
    sqlite_static_lib: []const u8,
    // MLX bundle (libmlx.a + libemlx.a) — empty mlx_dir means MLX is off.
    mlx_static: bool = false,
    mlx_dir: []const u8 = "",
    // NxEigen. Empty nxeigen_dir / false nxeigen_static = NxEigen is off.
    nxeigen_static: bool = false,
    nxeigen_dir: []const u8 = "",
    // Comma-separated absolute paths to project-side Rust NIF .a files.
    // Empty if the project has no Rust NIFs.
    project_rust_libs: []const u8,
    // Plugin cpp_archive `.a` archives (comma-separated abs paths). Same link
    // shape as project_rust_libs. Empty if no cpp_archive plugin is active.
    plugin_static_libs: []const u8 = "",
    // Plugin-contributed extra iOS frameworks (comma-separated).
    plugin_frameworks: []const u8 = "",
    objects: []const std.Build.LazyPath,
};

fn addLink(b: *std.Build, step: *std.Build.Step, opts: LinkOptions) void {
    const run = b.addSystemCommand(&.{
        "xcrun",
        "-sdk",
        "iphoneos",
        "swiftc",
        "-target",
        "arm64-apple-ios17.0",
    });

    // All compiled object files. addFileArg propagates the dependency so
    // each .o's compile step is implicitly required by the link step.
    for (opts.objects) |obj| run.addFileArg(obj);

    // OTP + crypto static libs. Same order as the iOS sim link (and the
    // prior CMake-based device link). Order matters — libbeam.a first so
    // its erts_static_nif_tab[] override resolves against driver_tab_ios.o
    // before the BEAM's own empty default.
    const lib_names = [_][]const u8{
        "lib/libbeam.a",
        "lib/internal/liberts_internal_r.a",
        "lib/internal/libethread.a",
        "lib/libzstd.a",
        "lib/libepcre.a",
        "lib/libryu.a",
        "lib/asn1rt_nif.a",
        "lib/crypto.a",
        "lib/libcrypto.a",
    };
    for (lib_names) |name| {
        run.addArg(b.fmt("{s}/{s}/{s}", .{ opts.otp_root, opts.erts_vsn, name }));
    }

    // Optional static-link of the exqlite NIF (passed by build_device.sh
    // when the project depends on exqlite).
    if (opts.sqlite_static_lib.len > 0) {
        run.addArg(opts.sqlite_static_lib);
    }

    // MLX + EMLX static archives, wired in when `mix mob.enable mlx` set
    // mlx_static=true and mob_dev passed the cached bundle path through
    // mlx_dir. libemlx.a holds the NIF (emlx_nif_nif_init); libmlx.a is
    // the upstream Apple MLX library.
    if (opts.mlx_static and opts.mlx_dir.len > 0) {
        run.addArg(b.fmt("{s}/lib/libemlx.a", .{opts.mlx_dir}));
        run.addArg(b.fmt("{s}/lib/libmlx.a", .{opts.mlx_dir}));
    }

    // NxEigen (Eigen-backed Nx backend, C++ NIF). Wired in when
    // `mix mob.enable nxeigen` set nxeigen_static=true and mob_dev passed
    // the per-arch build dir through nxeigen_dir. Eigen is header-only,
    // so there's no second library to link — just libnx_eigen.a.
    if (opts.nxeigen_static and opts.nxeigen_dir.len > 0) {
        run.addArg(b.fmt("{s}/libnx_eigen.a", .{opts.nxeigen_dir}));
    }

    // Project-side Rust NIF static archives (auto-wired from mob.exs
    // :static_nifs entries that have a native/<name>/Cargo.toml). mob_dev
    // cross-compiles each with `cargo rustc --target aarch64-apple-ios
    // --crate-type staticlib` before invoking zig.
    if (opts.project_rust_libs.len > 0) {
        var rust_it = std.mem.splitScalar(u8, opts.project_rust_libs, ',');
        while (rust_it.next()) |lib_path| {
            if (lib_path.len == 0) continue;
            // `addFileArg` (not `addArg`) so the cache key picks up the
            // contents of the .a, not just its path. Otherwise rebuilding
            // a project-side rust crate produces a new .a that the link
            // step ignores as UP-TO-DATE.
            const lp: std.Build.LazyPath = .{ .cwd_relative = lib_path };
            run.addFileArg(lp);
        }
    }

    // Plugin cpp_archive NIFs (e.g. an Nx CPU backend). Each lib<mod>.a exports
    // <mod>_nif_init, referenced by driver_tab_ios, so the linker pulls it in —
    // same mechanism as project_rust_libs / libnx_eigen.a above. addFileArg so
    // the cache key tracks archive contents.
    if (opts.plugin_static_libs.len > 0) {
        var ps_it = std.mem.splitScalar(u8, opts.plugin_static_libs, ',');
        while (ps_it.next()) |lib_path| {
            if (lib_path.len == 0) continue;
            const lp: std.Build.LazyPath = .{ .cwd_relative = lib_path };
            run.addFileArg(lp);
        }
    }

    run.addArgs(&.{ "-lz", "-lc++", "-lpthread" });
    run.addArgs(&.{ "-Xlinker", "-dead_strip" });
    const frameworks_base = [_][]const u8{
        "UIKit",
        "Foundation",
        "CoreGraphics",
        "QuartzCore",
        "SwiftUI",
    };
    for (frameworks_base) |fw| {
        run.addArgs(&.{ "-Xlinker", "-framework", "-Xlinker", fw });
    }

    // Plugin-contributed frameworks (gathered by mob_dev from activated
    // manifests). ld dedups -framework args so overlap with the base list
    // is harmless.
    if (opts.plugin_frameworks.len > 0) {
        var fw_it = std.mem.splitScalar(u8, opts.plugin_frameworks, ',');
        while (fw_it.next()) |fw| {
            if (fw.len == 0) continue;
            run.addArgs(&.{ "-Xlinker", "-framework", "-Xlinker", fw });
        }
    }

    // MLX-CPU uses Apple's Accelerate framework (vectorized BLAS/LAPACK
    // tuned for Apple silicon; available on iOS device + sim). When we
    // later ship the Metal variant, add Metal + MetalPerformanceShaders
    // here behind a separate option.
    if (opts.mlx_static) {
        run.addArgs(&.{ "-Xlinker", "-framework", "-Xlinker", "Accelerate" });
    }

    run.addArg("-o");
    const binary = run.addOutputFileArg(opts.module_name);

    const install = b.addInstallFile(binary, opts.module_name);
    step.dependOn(&install.step);
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
