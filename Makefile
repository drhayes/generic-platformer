# All the dang dirs.
ASSETS_DIR := assets
IMAGE_ASSETS_DIR := $(ASSETS_DIR)/images
SPRITE_ASSETS_DIR := $(ASSETS_DIR)/sprites
TILE_ASSETS_DIR := $(ASSETS_DIR)/tiles
TILEMAP_ASSETS_DIR := $(ASSETS_DIR)/tilemaps
MEDIA_DIR := media
IMAGES_DIR := $(MEDIA_DIR)/images
JSON_DIR := $(MEDIA_DIR)/json
TILEMAPS_DIR := $(MEDIA_DIR)/tilemaps
SRC_DIR := src
TMP_DIR := tmp
SPRITES_TMP := $(TMP_DIR)/sprites
TILES_TMP := $(TMP_DIR)/tiles


# All the dang assets.
SPRITE_ASSETS := $(wildcard $(SPRITE_ASSETS_DIR)/*.ase)
TILE_ASSETS := $(wildcard $(TILE_ASSETS_DIR)/*.ase)
TILEMAP_ASSETS := $(wildcard $(TILEMAP_ASSETS_DIR)/*.tmx)


# Programs I use.
ASEPRITE=/usr/bin/aseprite
TEXTUREPACKER=/usr/bin/TexturePacker
TILED=/home/drhayes/bin/Tiled-1.4.1-x86_64.AppImage


# Generated stuff.
# Sprites.
SPRITE_MARKERS=$(patsubst $(SPRITE_ASSETS_DIR)/%.ase,$(SPRITES_TMP)/%.spritemarker,$(SPRITE_ASSETS))
# Tiles.
TILE_MARKERS=$(patsubst $(TILE_ASSETS_DIR)/%.ase,$(TILES_TMP)/%.tilemarker,$(TILE_ASSETS))
CONVERTED_TILEMAPS=$(patsubst $(TILEMAP_ASSETS_DIR)/%.tmx,$(TILEMAPS_DIR)/%.lua,$(TILEMAP_ASSETS))


###############
# The Phonies #
###############

.PHONY: start
start: $(SRC_DIR)/media $(SRC_DIR)/lib tiles media/images/icon.png tilemaps sprites
	@exec love $(SRC_DIR)

.PHONY: sprites
sprites: $(IMAGES_DIR)/sprites.png $(JSON_DIR)/sprites.json

.PHONY: tiles
tiles: $(IMAGES_DIR)/tiles.png $(JSON_DIR)/tiles.json

.PHONY: tilemaps
tilemaps: $(CONVERTED_TILEMAPS)

.PHONY: clean
clean:
	rm -rf $(TMP_DIR)
	rm -rf $(IMAGES_DIR)/icon.png
	rm -rf $(IMAGES_DIR)/tiles.png
	rm -rf $(JSON_DIR)/tiles.json
	rm -rf $(IMAGES_DIR)/sprites.png
	rm -rf $(JSON_DIR)/sprites.json
	rm -rf $(TILEMAPS_DIR)


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

$(SPRITES_TMP):
	mkdir -p $@


###########
# Sprites #
###########

$(IMAGES_DIR)/sprites.png $(JSON_DIR)/sprites.json: $(SPRITE_MARKERS) | $(IMAGES_DIR) $(JSON_DIR)
	$(TEXTUREPACKER) $(SPRITES_TMP)/*.png --format json --data $(JSON_DIR)/sprites.json --sheet $(IMAGES_DIR)/sprites.png --trim-mode None --disable-rotation --force-squared

$(SPRITES_TMP)/%.spritemarker: $(SPRITE_ASSETS_DIR)/%.ase | $(SPRITES_TMP)
	$(ASEPRITE) --batch $< --save-as '$(SPRITES_TMP)/$*-{frame000}.png' && \
		$(ASEPRITE) --batch --list-tags $< --filename-format '$*-{frame000}.png' --data '$(JSON_DIR)/$*-animation.json' && \
		touch $@


#########
# Tiles #
#########

$(IMAGES_DIR)/tiles.png $(JSON_DIR)/tiles.json: $(TILE_MARKERS) | $(IMAGES_DIR) $(JSON_DIR)
	$(TEXTUREPACKER) $(TILES_TMP)/*.png --format json --data $(JSON_DIR)/tiles.json --sheet $(IMAGES_DIR)/tiles.png --trim-mode None --disable-rotation --force-squared

$(TILES_TMP)/%.tilemarker: $(TILE_ASSETS_DIR)/%.ase | $(TILES_TMP)
	$(ASEPRITE) --batch --split-slices $< --save-as '$(TILES_TMP)/$*-{slice}.png' && \
		touch $@


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
