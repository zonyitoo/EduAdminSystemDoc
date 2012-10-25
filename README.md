# 教务系统分析与设计文档
大三软件工程课程作业，教务系统分析与设计文档

## 依赖
* “华文中宋”中文字体，名字为`STZhongsong`
* CJKutf8

## 编译
* 安装字体
进入`mkfont`目录，修改`mkfont.sh`

```bash
...
TEXMF=~/.textmf-var  ## 这里修改为你系统中latex字体存放的地方
...
```
执行`mkfont.sh`生成字体(STZhongsong)
```bash
./mkfont.sh STZhongsong.ttf STZhongsong STZhongsong
```

* 使用`pdflatex`编译

```bash
pdflatex main.tex
```

注意：需编译两次才能生成目录
