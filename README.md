# JapanGridShift

Japanese datumgrid files - tky2jgd.gsb and touhokutaiheiyouoki2011.gsb.

### Japan: Tokyo Datum -> JGD2000

*Source*: [Geospatial Information Authority of Japan](https://www.gsi.go.jp/sokuchikijun/tky2jgd_download.html)  
*Format*: NTv2  
*License*: [Geospatial Information Authority of Japan Website Terms of Use](https://www.gsi.go.jp/ENGLISH/page_e30286.html) (compatible with the Creative Commons Attribution License 4.0)  

* tky2jgd.gsb (converted from [TKY2JGD.par](https://www.gsi.go.jp/sokuchikijun/tky2jgd_download.html) Ver.2.1.2)

#### check transformation

```
$ cs2cs
Rel. 6.0.0, March 1st, 2019
usage: cs2cs [ -dDeEfIlrstvwW [args] ] [ +opts[=arg] ]
                   [+to [+opts[=arg] [ files ]

$ echo 140.026224 38.546789 | cs2cs -v -f '%.10f' +proj=latlong +ellps=bessel +towgs84=-146.414,507.337,680.507 +nadgrids=./tky2jgd.gsb,null +to +proj=latlong +ellps=GRS80 +towgs84=0,0,0
# ---- From Coordinate System ----
+proj=latlong +ellps=bessel +towgs84=-146.414,507.337,680.507 +nadgrids=./tky2jgd.gsb,null
# ---- To Coordinate System ----
+proj=latlong +ellps=GRS80 +towgs84=0,0,0
140.0228535294	38.5497034780 0.0000000000
```



### Japan: JGD2000 -> JGD2011 (horizontal)

*Source*: [Geospatial Information Authority of Japan](https://www.gsi.go.jp/sokuchikijun/sokuchikijun41012.html#zahyo)  
*Format*: NTv2  
*License*: [Geospatial Information Authority of Japan Website Terms of Use](https://www.gsi.go.jp/ENGLISH/page_e30286.html) (compatible with the Creative Commons Attribution License 4.0)  

* touhokutaiheiyouoki2011.gsb (converted from [touhokutaiheiyouoki2011.par](https://www.gsi.go.jp/sokuchikijun/sokuchikijun41012.html#zahyo) Ver.4.0.0)

#### check transformation

```
$ cs2cs
Rel. 6.0.0, March 1st, 2019
usage: cs2cs [ -dDeEfIlrstvwW [args] ] [ +opts[=arg] ]
                   [+to [+opts[=arg] [ files ]

$ echo 140.026224 38.546789 | cs2cs -v -f '%.10f' +proj=latlong +ellps=GRS80 +towgs84=0,0,0 +nadgrids=./touhokutaiheiyouoki2011.gsb,null +to +proj=latlong +ellps=GRS80 +towgs84=0,0,0
# ---- From Coordinate System ----
+proj=latlong +ellps=GRS80 +towgs84=0,0,0 +nadgrids=./touhokutaiheiyouoki2011.gsb,null
# ---- To Coordinate System ----
+proj=latlong +ellps=GRS80 +towgs84=0,0,0
140.0262429300	38.5467840063 0.0000000000
```
