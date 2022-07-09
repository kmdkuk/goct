# Build flags
BUILD_FILES = $(shell go list -f '{{range .GoFiles}}{{$$.Dir}}/{{.}}\
{{end}}' ./...)
VERSION := $(shell git describe --tags $(shell git rev-list --tags --max-count=1))
DATE_FMT = +%Y-%m-%d
ifdef SOURCE_DATE_EPOCH
	BUILD_DATE ?= $(shell date -u -d "@$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u -r "$(SOURCE_DATE_EPOCH)" "$(DATE_FMT)" 2>/dev/null || date -u "$(DATE_FMT)")
else
	BUILD_DATE ?= $(shell date "$(DATE_FMT)")
endif

REVISION := $(shell git rev-parse --short HEAD)

ifndef CGO_CPPFLAGS
	export CGO_CPPFLAGS := $(CPPFLAGS)
endif
ifndef CGO_CFLAGS
	export CGO_CFLAGS := $(CFLAGS)
endif
ifndef CGO_LDFLAGS
	export CGO_LDFLAGS := $(LDFLAGS)
endif

GO_LDFLAGS := -X github.com/kmdkuk/goct/pkg/version.Revision=$(REVISION) $(GO_LDFLAGS)
GO_LDFLAGS := -X github.com/kmdkuk/goct/pkg/version.BuildDate=$(BUILD_DATE) $(GO_LDFLAGS)
DEV_LDFLAGS := $(GO_LDFLAGS)
GO_LDFLAGS := -X github.com/kmdkuk/goct/pkg/version.Version=$(VERSION) $(GO_LDFLAGS)

# Tools path
BIN_DIR := $(CURDIR)/bin

# Tools version
MDBOOK_VERSION = 0.4.19

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build

build: $(BUILD_FILES) ## Build binary
	go build -trimpath -ldflags "$(GO_LDFLAGS)" -o $(BIN_DIR)/ .

##@ Development

.PHONY: test
test: lint ## Run lint & test.
	go test ./...

.PHONY: lint
lint: staticcheck ## Run lint
	test -z "$$(gofmt -s -l . | tee /dev/stderr)"
	$(STATICCHECK) ./...
	go vet ./...

##@ Documentations

.PHONY: book
book: mdbook
	rm -rf docs/book
	cd docs; $(MDBOOK) build

.PHONY: serve-book
serve-book: mdbook
	cd docs; $(MDBOOK) serve

##@ Tools

MDBOOK := $(BIN_DIR)/mdbook
.PHONY: mdbook
mdbook: $(MDBOOK) ## Donwload mdbook locally if necessary
$(MDBOOK):
	mkdir -p $(BIN_DIR)
	curl -fsL https://github.com/rust-lang/mdBook/releases/download/v$(MDBOOK_VERSION)/mdbook-v$(MDBOOK_VERSION)-x86_64-unknown-linux-gnu.tar.gz | tar -C $(BIN_DIR) -xzf -

STATICCHECK := $(BIN_DIR)/staticcheck
.PHONY: staticcheck
staticcheck: $(STATICCHECK)

$(STATICCHECK):
	mkdir -p $(BIN_DIR)
	GOBIN=$(BIN_DIR) go install honnef.co/go/tools/cmd/staticcheck@latest
