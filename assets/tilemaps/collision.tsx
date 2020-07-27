<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.2" tiledversion="1.3.3" name="collision" tilewidth="16" tileheight="16" tilecount="3" columns="0">
 <grid orientation="orthogonal" width="1" height="1"/>
 <tile id="0">
  <properties>
   <property name="isSolid" type="bool" value="true"/>
  </properties>
  <image width="16" height="16" source="../../tmp/tiles/collisionTiles-solid.png"/>
 </tile>
 <tile id="1">
  <properties>
   <property name="isOneWayUp" type="bool" value="true"/>
  </properties>
  <image width="16" height="16" source="../../tmp/tiles/collisionTiles-one-way-up.png"/>
 </tile>
 <tile id="2">
  <properties>
   <property name="isHidden" type="bool" value="true"/>
  </properties>
  <image width="16" height="16" source="../../tmp/tiles/collisionTiles-hidden.png"/>
 </tile>
</tileset>
