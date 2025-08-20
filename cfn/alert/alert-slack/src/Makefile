build-Function:
	cp -r app pyproject.toml $(ARTIFACTS_DIR)
	uv lock --directory $(ARTIFACTS_DIR)
	uv export -q --directory $(ARTIFACTS_DIR) --frozen --no-dev --no-editable -o $(ARTIFACTS_DIR)/requirements.txt
	uv pip install -q --no-installer-metadata --no-compile-bytecode -r $(ARTIFACTS_DIR)/requirements.txt --target $(ARTIFACTS_DIR)
