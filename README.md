# ExportSWF
## 简介
本程序可以将swf导出成cocos2d-x使用的sprite sheets,支持导出单文件，也可以导出成每个素材独立的文件。与TexturePacker不同的是，本程序可以导出每一帧动画，并且可以支持特效，这点可以秒杀flash cc的导出sprite sheets（要不然我也不会写这个程序了）

## 使用说明

### 素材要求
在flash pro里面创建好影片剪辑，然后拖到舞台上，为它命名（这个会在生成的sprite sheets中使用）

## 导出步骤
先将素材发布成swf，然后打开本程序，选择swf作为输入文件，选择输出目录。接下来点击export 或者export single file。

export会给每个影片剪辑导出成不同文件，export single file会将舞台上所有影片剪辑导出到同一个文件
