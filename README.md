# JINS-MUSIC
JINS MEME ESから取得した集中力のデータに応じて、集中力を向上維持するために音楽をインタラクティブに変化させるIOSアプリ

## 背景
近年のオフィスでは、音楽を流すことは仕事に良い影響を与えるとして、オフィスで音楽を流す企業や個人がヘッドホンなどで音楽を聴くことを許可している企業が増加している。音楽を聴くことが脳に何らかの影響を及ぼし、集中力を高め、仕事の成果を向上させる効果があると言われている。
集中力と音楽の関係については、集中していない時にテンポの速い曲を聞くことでやる気が上昇し、集中状態への引き込みが行われる。また、集中力の上昇に合わせて、テンポを徐々に下げていくと、継続して集中力が高まっていく。更に、深い集中状態の時には、些細な雑音でも集中力が低下することから、音刺激は小さい方がよいと言われている。そこで、集中状態に適したリズムと音量の音楽を自動生成することで、集中力の向上・維持をサポートできると考えた。

## 調査
普段音楽を聴きながら知的業務をすると、集中状態
に至るまで、音楽には3つの役割ある。<br>
1つ目のやる気がない状態からやる気がある状態にするためには、テンポの速い音楽が適している。<br>
2つ目の深い集中状態にするためには、テンポの遅い曲 が適している。<br>
3つ目の集中状態を維持するためには、歌声がない音楽が適している。<br>

<strong>アンケート</strong><br>
「日常的に知的業務をする時に音楽を聴くか」や、普段から音楽を聴いて知的業務をする場合に「どのような曲を聴くか」など、音楽を聴きながら行う知的業務に関する実態調査を、19 歳から24歳までの 30 人にアンケートをおこなった。<br>
集中力を高めるために音楽を聴きながら知的業務を行なっているが、聴いている音楽が原因で集中力を妨げられているということがアンケート調査から分かった。<br>

<strong>課題</strong><br>
ゾーン状態と言われる極度の集中状態では、 些細な音や雑音などで、ゾーン状態から簡単に外れる。 そこで、ユーザーの集中状態に適した音楽を生成して、 ゾーン状態には音が聞こえなくなるようなシステムを 開発することが求められる。<br>

 ## システム
 集中力の測定データは、JINS MEME ES を顔に装着し、Bluetooth 通信によってスマートフォンに送ること ができる。受信したデータをもとに、スマートフォンの アプリケーションが集中力に応じた音楽を生成するよ うにシステムを構築する。
JINS MEME ES で取得できる集中力は、「あたま」、 「こころ」、「からだ」の総合点で測定されている。「あたま」は集中状態の深さを示す値で、まばたき の回数を眼電位センサで取得して得点をつけている。 「こころ」はリラックス状態を示す値で、まばたきの強 さの安定度を眼電位センサで測定して得点をつけてい る。「からだ」は姿勢が安定していることを示す値で、 頭部の動きの安定度を6軸モーションセンサで測定し て得点をつけている。この 3 つの得点の総合点を集中 力として取得することができる。音楽は amper music api で自動生成を行なっている。amper music api ではテンポと曲の長さの指定を 行うことで音楽ファイルを自動で作成し、音楽を取得 することができる。本研究では、曲のテンポによってリ ラックス状態が変化するということから、「こころ」の 値を元に曲のテンポを決め、ゾーン状態では音楽が集 中を妨げることから、「あたま」の値を元に音量を変化 させる。また、音楽を取得するたびに音楽がインタラク ティブに変化するため、音楽のつなぎ目がわかりやす いと集中力に影響すると考えた。そこで、次の音楽がフ ェードインしてから現在の音楽がフェードアウトする ことで、つなぎ目に違和感がないように再生するシス テムを開発した。常に集中力が向上する方向に促進す るシステムと、音楽のつなぎ目がわかりにくくするシ ステムを合わせてRITシステムを構築した。

 <img src="https://github.com/degudegu2510/JINS-MUSIC/blob/master/image/graph4.jpg?raw=true">
 
 ## UI
 <strong>loading画面 + JINS MEME ES接続画面</strong><br>
 <img src="https://github.com/degudegu2510/JINS-MUSIC/blob/master/image/Lounch1-4.png?raw=true">
 <strong>メイン画面</strong><br>
 <img src="https://github.com/degudegu2510/JINS-MUSIC/blob/master/image/Main1-1%20%E2%80%93%201.png">
