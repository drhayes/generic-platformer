# All the dang dirs.
ASSETS_DIR := assets
TILE_ASSETS_DIR := $(ASSETS_DIR)/tiles
MEDIA_DIR := media
IMAGES_DIR := $(MEDIA_DIR)/images
JSON_DIR := $(MEDIA_DIR)/json

TMP_DIR := tmp
TILES_TMP := $(TMP_DIR)/tiles

# All the dang assets.
TILE_ASSETS := $(wildcard $(TILE_ASSETS_DIR)/*.ase)


# Programs I use.
ASEPRITE=/usr/bin/aseprite
TEXTUREPACKER=/usr/bin/TexturePacker

# Generated stuff.
# Tiles.
TILE_MARKERS=$(patsubst $(TILE_ASSETS_DIR)/%.ase,$(TILES_TMP)/%.tilemarker,$(TILE_ASSETS))


###############
# The Phonies #
###############

.PHONY: start
start: tiles
	echo Starting...

.PHONY: tiles
tiles: $(IMAGES_DIR)/tiles.png $(JSON_DIR)/tiles.json


###############
# Directories #
###############

$(IMAGES_DIR):
	mkdir -p $@

$(JSON_DIR):
	mkdir -p $@

$(TILES_TMP):
	mkdir -p $@

#########
# Tiles #
#########

$(IMAGES_DIR)/tiles.png $(JSON_DIR)/tiles.json: $(TILE_MARKERS) | $(IMAGES_DIR) $(JSON_DIR)
	$(TEXTUREPACKER) $(TILES_TMP)/*.png --format json --data $(JSON_DIR)/tiles.json --sheet $(IMAGES_DIR)/tiles.png --trim-mode None --disable-rotation --force-squared

$(TILES_TMP)/%.tilemarker: $(TILE_ASSETS_DIR)/%.ase | $(TILES_TMP)
	$(ASEPRITE) --batch --split-slices $< --save-as '$(TILES_TMP)/$*-{slice}.png' && touch $@
