.PHONY: all generate docs clean check-plugins

PROTO_DIR := proto
OUT_DIR := gen
DOCS_DIR := docs
PROTO_FILES := $(shell find $(PROTO_DIR) -name "*.proto")

PROTOC_GEN_GO := $(shell which protoc-gen-go)
PROTOC_GEN_GO_GRPC := $(shell which protoc-gen-go-grpc)
PROTOC_GEN_DOC := $(shell which protoc-gen-doc)

all: check-plugins generate docs

# Проверка плагинов
check-plugins:
	@if [ -z "$(PROTOC_GEN_GO)" ]; then \
	  echo "❌ protoc-gen-go не найден. Нужно установить:"; \
	  echo "  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest"; \
	  exit 1; \
	fi
	@if [ -z "$(PROTOC_GEN_GO_GRPC)" ]; then \
	  echo "❌ protoc-gen-go-grpc не найден. Нужно установить:"; \
	  echo "  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"; \
	  exit 1; \
	fi
	@if [ -z "$(PROTOC_GEN_DOC)" ]; then \
	  echo "❌ protoc-gen-doc не найден. Нужно установить:"; \
	  echo "  go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest"; \
	  exit 1; \
	fi

# Генерация Go-кода
generate:
	@echo "Генерация Go-кода"
	@mkdir -p $(OUT_DIR)
	protoc -I $(PROTO_DIR) \
		--plugin=protoc-gen-go=$(PROTOC_GEN_GO) \
		--plugin=protoc-gen-go-grpc=$(PROTOC_GEN_GO_GRPC) \
		$(PROTO_FILES) \
		--go_out=$(OUT_DIR) --go_opt=paths=source_relative \
		--go-grpc_out=$(OUT_DIR) --go-grpc_opt=paths=source_relative

# Генерация HTML-документации
docs:
	@echo "Генерация HTML-документации"
	@rm -rf $(DOCS_DIR)
	@mkdir -p $(DOCS_DIR)
	protoc -I $(PROTO_DIR) \
		--plugin=protoc-gen-doc=$(PROTOC_GEN_DOC) \
		$(PROTO_FILES) \
		--doc_out=$(DOCS_DIR) --doc_opt=html,index.html

# Очистка
clean:
	rm -rf $(OUT_DIR) $(DOCS_DIR)
