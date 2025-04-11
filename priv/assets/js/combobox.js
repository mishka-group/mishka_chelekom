let Combobox = {
  mounted() {
    this.initElements();

    this.boundHandleScroll = this.updateDropdownPosition.bind(this);
    this.boundHandleKeyDown = this.handleKeyDown.bind(this);
    this.boundHandleDocumentClick = this.handleDocumentClick.bind(this);
    this.boundOpenButtonClick = this.handleOpenButtonClick.bind(this);
    this.boundOptionClickHandlers = [];
    this.boundClearButtonClick = this.handleClearButtonClick.bind(this);

    this.lastNavigatedValue = null; // last chosen option

    if (!this.openButton.id) {
      this.openButton.id = `combobox-trigger-${Math.random()
        .toString(36)
        .substring(2, 9)}`;
    }

    this.openButton.addEventListener("click", this.boundOpenButtonClick);

    this.el.querySelectorAll(".combobox-option").forEach((btn) => {
      const handler = this.handleOptionClick.bind(this);
      btn.addEventListener("click", handler);
      this.boundOptionClickHandlers.push({ btn, handler });
    });

    if (this.searchInput) {
      this.boundSearchInputHandler = this.handleSearch.bind(this);
      this.searchInput.addEventListener("input", this.boundSearchInputHandler);
    }

    if (this.clearButton) {
      this.clearButton.addEventListener("click", this.boundClearButtonClick);
    }

    document.addEventListener("click", this.boundHandleDocumentClick, true);

    this.observer = new MutationObserver(() => {
      this.syncDisplayFromSelect();
    });
    this.observer.observe(this.select, {
      attributes: true,
      childList: true,
      subtree: true,
    });

    this.syncDisplayFromSelect();
  },

  initElements() {
    this.select = this.el.querySelector(".combo-select");
    this.dropdown = this.el.querySelector('[data-part="listbox"]');
    this.openButton = this.el.querySelector(".combobox-trigger");
    this.selectedDisplay = this.el.querySelector(".selected-value");
    this.searchInput = this.el.querySelector(".combobox-search-input");
    this.clearButton = this.el.querySelector(
      '[data-part="clear-combobox-button"]',
    );
    this.dropdownOptions = this.el.querySelectorAll(".combobox-option");
  },

  handleOpenButtonClick(e) {
    e.preventDefault();
    e.stopPropagation();
    if (this.dropdown.hasAttribute("hidden")) {
      this.openDropdown();
    } else {
      this.closeDropdown();
    }
  },

  openDropdown() {
    this.dropdown.removeAttribute("hidden");
    this.openButton.setAttribute("aria-expanded", "true");

    requestAnimationFrame(() => {
      this.updateDropdownPosition();
      this.dropdownOptions = this.el.querySelectorAll(".combobox-option");

      let navigateTarget = null;
      if (this.lastNavigatedValue) {
        navigateTarget = this.el.querySelector(
          `.combobox-option[data-combobox-value="${this.lastNavigatedValue}"]`,
        );
      }
      if (!navigateTarget) {
        navigateTarget = this.el.querySelector(
          ".combobox-option[data-combobox-selected]",
        );
      }
      if (!navigateTarget && this.dropdownOptions.length > 0) {
        navigateTarget = this.dropdownOptions[0];
      }

      this.dropdownOptions.forEach((opt) =>
        opt.removeAttribute("data-combobox-navigate"),
      );

      if (navigateTarget) {
        navigateTarget.setAttribute("data-combobox-navigate", "");
        navigateTarget.scrollIntoView({ block: "nearest" });
        this.lastNavigatedValue = navigateTarget.dataset.comboboxValue;
        if (navigateTarget.id) {
          this.openButton.setAttribute(
            "aria-activedescendant",
            navigateTarget.id,
          );
        } else {
          this.openButton.removeAttribute("aria-activedescendant");
        }
      } else {
        this.openButton.removeAttribute("aria-activedescendant");
      }

      if (this.searchInput) {
        this.searchInput.focus();
      }
    });

    window.addEventListener("scroll", this.boundHandleScroll, {
      passive: true,
    });
    document.addEventListener("keydown", this.boundHandleKeyDown);
  },

  closeDropdown() {
    if (!this.dropdown.hasAttribute("hidden")) {
      this.dropdown.setAttribute("hidden", true);
    }
    this.openButton.setAttribute("aria-expanded", "false");
    this.openButton.removeAttribute("aria-activedescendant");
    window.removeEventListener("scroll", this.boundHandleScroll);
    document.removeEventListener("keydown", this.boundHandleKeyDown);
  },

  resetNavigateToFirstOption() {
    this.el.querySelectorAll(".combobox-option").forEach((opt) => {
      opt.removeAttribute("data-combobox-navigate");
    });
    const firstOption = this.el.querySelector(".combobox-option");
    if (firstOption) {
      firstOption.setAttribute("data-combobox-navigate", "");
      firstOption.scrollIntoView({ block: "nearest" });
      this.lastNavigatedValue = firstOption.dataset.comboboxValue;
      if (firstOption.id) {
        this.openButton.setAttribute("aria-activedescendant", firstOption.id);
      }
    }
  },

  updateDropdownPosition() {
    const rect = this.openButton.getBoundingClientRect();
    const dropdownHeight = this.dropdown.offsetHeight || 200;
    const windowHeight = window.innerHeight;
    const spaceBelow = windowHeight - rect.bottom;
    if (spaceBelow < dropdownHeight) {
      this.dropdown.classList.remove("top-full", "mt-2");
      this.dropdown.classList.add("bottom-full", "mb-2");
    } else {
      this.dropdown.classList.remove("bottom-full", "mb-2");
      this.dropdown.classList.add("top-full", "mt-2");
    }
  },

  handleSearch(e) {
    const query = e.target.value.toLowerCase();
    this.dropdownOptions = this.el.querySelectorAll(".combobox-option");

    this.dropdownOptions.forEach((option) => {
      const valueAttr = option
        .getAttribute("data-combobox-value")
        .toLowerCase();
      option.style.display = valueAttr.includes(query) ? "" : "none";
    });

    const noResults = this.el.querySelector(".no-results");
    const visibleOptions = Array.from(this.dropdownOptions).filter(
      (option) => option.style.display !== "none",
    );
    if (visibleOptions.length === 0) {
      noResults.classList.remove("hidden");
    } else {
      noResults.classList.add("hidden");
    }

    this.el.querySelectorAll(".option-group").forEach((group) => {
      const visibleInGroup = group.querySelectorAll(
        '.combobox-option:not([style*="display: none"])',
      );
      group.style.display = visibleInGroup.length === 0 ? "none" : "";
    });

    this.dropdownOptions.forEach((option) =>
      option.removeAttribute("data-combobox-navigate"),
    );
    if (visibleOptions.length > 0) {
      visibleOptions[0].setAttribute("data-combobox-navigate", "");
    }
  },

  handleOptionClick(e) {
    e.preventDefault();
    const optionEl = e.target.closest(".combobox-option");
    const value = optionEl.dataset.comboboxValue;
    const isMultiple = this.select.multiple;
    if (isMultiple) {
      this.toggleOption(value, optionEl);
      this.updateMultipleSelectedDisplay();
      this.dispatchChangeEvent();
    } else {
      this.el.querySelectorAll(".combobox-option").forEach((opt) => {
        opt.removeAttribute("data-combobox-selected");
        opt.setAttribute("aria-selected", "false");
      });
      this.selectSingleOption(value);
      optionEl.setAttribute("data-combobox-selected", "");
      optionEl.setAttribute("aria-selected", "true");
      this.closeDropdown();
      this.openButton.focus();
    }
  },

  toggleOption(value, optionEl) {
    const option = Array.from(this.select.options).find(
      (opt) => opt.value === value,
    );
    if (option) {
      option.selected = !option.selected;
      if (option.selected) {
        option.setAttribute("selected", "");
        optionEl.setAttribute("data-combobox-selected", "");
        optionEl.setAttribute("aria-selected", "true");
      } else {
        option.removeAttribute("selected");
        optionEl.removeAttribute("data-combobox-selected");
        optionEl.setAttribute("aria-selected", "false");
      }
    }
  },

  selectSingleOption(value) {
    Array.from(this.select.options).forEach((opt) => {
      opt.selected = opt.value === value;
    });
    this.updateSingleSelectedDisplay();
    this.dispatchChangeEvent();
  },

  updateSingleSelectedDisplay() {
    this.el.querySelectorAll(".combobox-option").forEach((opt) => {
      opt.removeAttribute("data-combobox-selected");
      opt.setAttribute("aria-selected", "false");
    });

    const selectedOption = Array.from(this.select.options).find(
      (opt) => opt.selected && opt.value !== "",
    );
    const placeholder = this.el.querySelector(".combobox-placeholder");
    const clearBtn = this.el.querySelector(
      '[data-part="clear-combobox-button"]',
    );

    if (selectedOption) {
      if (placeholder) placeholder.style.display = "none";
      const renderedOption = this.el.querySelector(
        `.combobox-option[data-combobox-value="${selectedOption.value}"]`,
      );
      this.selectedDisplay.innerHTML = renderedOption
        ? renderedOption.innerHTML
        : selectedOption.textContent;
      if (renderedOption) {
        renderedOption.setAttribute("data-combobox-selected", "");
        renderedOption.setAttribute("aria-selected", "true");
      }
      if (clearBtn) clearBtn.hidden = false;
    } else {
      if (placeholder) placeholder.style.display = "";
      this.selectedDisplay.textContent = "";
      if (clearBtn) clearBtn.hidden = true;
      this.lastNavigatedValue = null;
    }
  },

  updateMultipleSelectedDisplay() {
    this.selectedDisplay.innerHTML = "";
    const selectedOptions = Array.from(this.select.options).filter(
      (opt) => opt.selected,
    );
    const placeholder = this.el.querySelector(".combobox-placeholder");
    const clearBtn = this.el.querySelector(
      '[data-part="clear-combobox-button"]',
    );

    if (selectedOptions.length > 0) {
      placeholder.style.display = "none";
      if (clearBtn) clearBtn.hidden = false;
    } else {
      placeholder.style.display = "";
      if (clearBtn) clearBtn.hidden = true;
    }

    selectedOptions.forEach((option) => {
      const optionEl = this.el.querySelector(
        `.combobox-option[data-combobox-value="${option.value}"]`,
      );
      if (optionEl) {
        optionEl.setAttribute("data-combobox-selected", "");
        optionEl.setAttribute("aria-selected", "true");
      }
    });

    selectedOptions.forEach((option) => {
      const pill = document.createElement("span");
      pill.classList.add(
        "selected-item",
        "flex",
        "items-center",
        "gap-2",
        "combobox-pill",
      );

      const renderedOption = this.el.querySelector(
        `.combobox-option[data-combobox-value="${option.value}"]`,
      );
      if (renderedOption) {
        pill.innerHTML = renderedOption.innerHTML;
      } else {
        pill.textContent = option.textContent;
      }

      const closeBtn = document.createElement("span");
      closeBtn.innerHTML =
        '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="combobox-icon"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>';
      closeBtn.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        option.selected = false;
        option.removeAttribute("selected");
        const optionEl = this.el.querySelector(
          `.combobox-option[data-combobox-value="${option.value}"]`,
        );
        if (optionEl) {
          optionEl.removeAttribute("data-combobox-selected");
          optionEl.setAttribute("aria-selected", "false");
        }
        this.updateMultipleSelectedDisplay();
        this.dispatchChangeEvent();
      });
      pill.appendChild(closeBtn);
      this.selectedDisplay.appendChild(pill);
    });
  },

  handleKeyDown(e) {
    const key = e.key;
    if (key === "Escape") {
      this.closeDropdown();
      return;
    }

    if (
      document.activeElement === this.searchInput &&
      !["ArrowDown", "ArrowUp", "Enter"].includes(key)
    ) {
      return;
    }

    if (this.dropdown.hasAttribute("hidden")) return;

    const visibleOptions = Array.from(
      this.el.querySelectorAll(".combobox-option"),
    ).filter((opt) => opt.style.display !== "none");
    if (visibleOptions.length === 0) return;

    let currentIndex = visibleOptions.findIndex((opt) =>
      opt.hasAttribute("data-combobox-navigate"),
    );

    if (key === "ArrowDown") {
      currentIndex = (currentIndex + 1) % visibleOptions.length;
      e.preventDefault();
    } else if (key === "ArrowUp") {
      currentIndex =
        (currentIndex - 1 + visibleOptions.length) % visibleOptions.length;
      e.preventDefault();
    } else if (key === "Enter") {
      e.preventDefault();
      if (currentIndex >= 0) visibleOptions[currentIndex].click();
      if (!this.select.multiple) this.closeDropdown();
      return;
    } else if (key.length === 1) {
      e.preventDefault();
      this.handleCharacterNavigation(key.toLowerCase(), visibleOptions);
      return;
    } else {
      return;
    }

    visibleOptions.forEach((opt) =>
      opt.removeAttribute("data-combobox-navigate"),
    );
    visibleOptions[currentIndex].setAttribute("data-combobox-navigate", "");
    visibleOptions[currentIndex].scrollIntoView({ block: "nearest" });
    this.lastNavigatedValue =
      visibleOptions[currentIndex].dataset.comboboxValue;
    if (visibleOptions[currentIndex].id) {
      this.openButton.setAttribute(
        "aria-activedescendant",
        visibleOptions[currentIndex].id,
      );
    } else {
      this.openButton.removeAttribute("aria-activedescendant");
    }
  },

  handleCharacterNavigation(char, options) {
    const matchingOptions = options.filter((opt) => {
      const valueAttr = opt.getAttribute("data-combobox-value") || "";
      const labelText = opt.textContent.trim().toLowerCase();
      return (
        valueAttr.toLowerCase().startsWith(char) || labelText.startsWith(char)
      );
    });
    if (matchingOptions.length === 0) return;

    let currentIndex = matchingOptions.findIndex((opt) =>
      opt.hasAttribute("data-combobox-navigate"),
    );
    currentIndex = (currentIndex + 1) % matchingOptions.length;

    options.forEach((opt) => opt.removeAttribute("data-combobox-navigate"));
    matchingOptions[currentIndex].setAttribute("data-combobox-navigate", "");
    matchingOptions[currentIndex].scrollIntoView({ block: "nearest" });
  },

  syncDisplayFromSelect() {
    this.el.querySelectorAll(".combobox-option").forEach((opt) => {
      opt.removeAttribute("data-combobox-selected");
      opt.removeAttribute("data-combobox-navigate");
      opt.setAttribute("aria-selected", "false");
    });

    if (this.select.multiple) {
      this.updateMultipleSelectedDisplay();
    } else {
      this.updateSingleSelectedDisplay();
    }

    const isAnySelected = Array.from(this.select.options).some(
      (opt) => opt.selected,
    );
    if (!isAnySelected) {
      this.resetNavigateToFirstOption();
    }
  },

  handleDocumentClick(e) {
    if (!this.el.contains(e.target) && !this.isClickOnScrollbar(e)) {
      this.closeDropdown();
    }
  },

  isClickOnScrollbar(e) {
    return (
      e.clientX >= document.documentElement.clientWidth ||
      e.clientY >= document.documentElement.clientHeight
    );
  },

  dispatchChangeEvent() {
    const changeEvent = new Event("change", { bubbles: true });
    this.select.dispatchEvent(changeEvent);
  },

  handleClearButtonClick(e) {
    e.preventDefault();
    e.stopPropagation();
    Array.from(this.select.options).forEach((opt) => {
      opt.selected = false;
      opt.removeAttribute("selected");
    });
    this.el.querySelectorAll(".combobox-option").forEach((opt) => {
      opt.removeAttribute("data-combobox-selected");
      opt.setAttribute("aria-selected", "false");
    });
    this.syncDisplayFromSelect();
    this.closeDropdown();
    this.dispatchChangeEvent();
    this.resetNavigateToFirstOption();
  },

  destroyed() {
    this.closeDropdown();
    if (this.observer) {
      this.observer.disconnect();
    }
    document.removeEventListener("click", this.boundHandleDocumentClick, true);
    if (this.openButton && this.boundOpenButtonClick) {
      this.openButton.removeEventListener("click", this.boundOpenButtonClick);
    }
    if (
      this.boundOptionClickHandlers &&
      this.boundOptionClickHandlers.length > 0
    ) {
      this.boundOptionClickHandlers.forEach(({ btn, handler }) => {
        btn.removeEventListener("click", handler);
      });
    }
    if (this.searchInput && this.boundSearchInputHandler) {
      this.searchInput.removeEventListener(
        "input",
        this.boundSearchInputHandler,
      );
    }
    if (this.clearButton && this.boundClearButtonClick) {
      this.clearButton.removeEventListener("click", this.boundClearButtonClick);
    }
  },
};

export default Combobox;
