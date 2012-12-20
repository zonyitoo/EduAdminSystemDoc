# 教务系统分析与设计文档
大三软件工程课程作业，教务系统分析与设计文档

## 依赖
* “华文中宋”中文字体，名字为`STZhongsong`
* ttf2pt1字体转换工具
* CJKutf8
* LaTeX

## 编译
### 安装字体

进入`mkfont`目录，修改`mkfont.sh`

```bash
...
TEXMF=~/.textmf-var  ## 这里修改为你系统中latex字体存放的地方（Ubuntu不用改）
...
```

安装`ttf2pt1`字体转换工具

```bash
tar -xvf ttf2pt1_3.4.4.orig.tar.gz
cd ttf2pt1-3.4.4/
make ## 不要make install，会出错
sudo cp ttf2pt1 t1asm /usr/bin/
```

执行`mkfont.sh`生成字体(STZhongsong)
```bash
./mkfont.sh STZhongsong.ttf stzhongsong stzhongsong
```

或者改变默认中文字体，于`main.tex`中
```tex
...
\begin{CJK*}{UTF8}{stzhongsong}  % 此处stzhongsong改为别的字体，如song
...
```

### 使用pdflatex编译

```bash
pdflatex main.tex
```

注意：需编译两次才能生成目录
