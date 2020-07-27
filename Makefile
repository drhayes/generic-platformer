# All the dang dirs.
ASSETS_DIR := assets
IMAGE_ASSETS_DIR := $(ASSETS_DIR)/images
TILE_ASSETS_DIR := $(ASSETS_DIR)/tiles
TILEMAP_ASSETS_DIR := $(ASSETS_DIR)/tilemaps
MEDIA_DIR := media
IMAGES_DIR := $(MEDIA_DIR)/images
JSON_DIR := $(MEDIA_DIR)/json
TILEMAPS_DIR := $(MEDIA_DIR)/tilemaps
SRC_DIR := src
TMP_DIR := tmp
TILES_TMP := $(TMP_DIR)/tiles


# All the dang assets.
TILE_ASSETS := $(wildcard $(TILE_ASSETS_DIR)/*.ase)
TILEMAP_ASSETS := $(wildcard $(TILEMAP_ASSETS_DIR)/*.tmx)


# Programs I use.
ASEPRITE=/usr/bin/aseprite
TEXTUREPACKER=/usr/bin/TexturePacker
TILED=/home/drhayes/bin/Tiled-1.3.3-x86_64.AppImage


# Generated stuff.
# Tiles.
TILE_MARKERS=$(patsubst $(TILE_ASSETS_DIR)/%.ase,$(TILES_TMP)/%.tilemarker,$(TILE_ASSETS))
CONVERTED_TILEMAPS=$(patsubst $(TILEMAP_ASSETS_DIR)/%.tmx,$(TILEMAPS_DIR)/%.lua,$(TILEMAP_ASSETS))


###############
# The Phonies #
###############

.PHONY: start
start: $(SRC_DIR)/media $(SRC_DIR)/lib tiles media/images/icon.png tilemaps
	@exec love $(SRC_DIR)

.PHONY: tiles
tiles: $(IMAGES_DIR)/tiles.png $(JSON_DIR)/tiles.json

.PHONY: tilemaps
tilemaps: $(CONVERTED_TILEMAPS)


###############
# Directories #
###############

$(SRC_DIR)/media:
	ln -s $(abspath $(MEDIA_DIR)) $(abspath $@)

$(SRC_DIR)/lib:
	ln -s $(abspath lib) $(abspath $@)

$(IMAGES_DIR):
	mkdir -p $@

$(JSON_DIR):
	mkdir -p $@

$(TILEMAPS_DIR):
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


############
# Tilemaps #
############

$(TILEMAPS_DIR)/%.lua: $(TILEMAP_ASSETS_DIR)/%.tmx | $(TILEMAPS_DIR)
	$(TILED) $< --export-map $@


########
# Misc #
########

media/images/icon.png: $(IMAGE_ASSETS_DIR)/icon.ase
	$(ASEPRITE) --batch $< --save-as $@
