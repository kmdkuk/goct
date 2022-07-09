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

BIN_DIR := $(CURDIR)/bin
STATICCHECK := $(BIN_DIR)/staticcheck

build: $(BUILD_FILES)
	go build -trimpath -ldflags "$(GO_LDFLAGS)" -o $(BIN_DIR)/ .

dev: $(BUILD_FILES)
	go build -trimpath -ldflags "$(DEV_LDFLAGS)" -o $(BIN_DIR)/dev .

test: $(STATICCHECK)
	test -z "$$(gofmt -s -l . | tee /dev/stderr)"
	$(STATICCHECK) ./...
	go vet ./...
	go test ./...
.PHONY: test

$(STATICCHECK):
	GOBIN=$(BIN_DIR) go install honnef.co/go/tools/cmd/staticcheck@latest
