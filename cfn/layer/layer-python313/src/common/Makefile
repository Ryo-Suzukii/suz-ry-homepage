build-CommonLayer:
	mkdir -p $(ARTIFACTS_DIR)/python
	cp pyproject.toml $(ARTIFACTS_DIR)/python
	uv lock --directory $(ARTIFACTS_DIR)/python
	uv export -q --directory $(ARTIFACTS_DIR)/python --frozen --no-dev --no-editable -o $(ARTIFACTS_DIR)/python/requirements.txt
	uv pip install -q --no-installer-metadata --no-compile-bytecode -r $(ARTIFACTS_DIR)/python/requirements.txt --target $(ARTIFACTS_DIR)/python
