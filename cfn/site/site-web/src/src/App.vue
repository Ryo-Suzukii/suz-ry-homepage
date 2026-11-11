<script setup>
import SkyCanvas from "./components/SkyCanvas.vue"
import { games, links, stack, tools, works } from "./data/profile.js"
</script>

<template>
  <SkyCanvas />

  <main class="page">
    <header class="hero">
      <h1 class="hero__name">Ryo Suzuki</h1>
      <p class="hero__handle">hayaa</p>
      <p class="hero__lead">AIエージェントをつくるエンジニアです。<wbr />星空が好きです。</p>
      <p class="hero__hint">下へ読み進めると、少しずつ空を見上げていきます。<br />ドラッグで見渡せます。</p>
    </header>

    <section class="block">
      <h2>いまやっていること</h2>
      <p>
        海運業界向けのBtoB SaaSで、ビジネスデータの分析基盤と、それを使うAIエージェントをつくっています。2024年から。
      </p>
      <p>画面からインフラまで、必要なところは全部さわるフルスタックエンジニアです。</p>
      <ul class="stack" aria-label="よく使う技術">
        <li v-for="name in stack" :key="name">{{ name }}</li>
      </ul>
    </section>

    <section class="block">
      <h2>つくったもの</h2>
      <p>仕事の外で、自分がほしくてつくったものです。</p>
      <ul class="works">
        <li v-for="work in works" :key="work.name">
          <h3>{{ work.name }}</h3>
          <p>{{ work.body }}</p>
          <p class="works__made">{{ work.made }}</p>
        </li>
      </ul>
    </section>

    <section class="block">
      <h2>好きなもの</h2>
      <p>星空。このページの背景を本物の空にしたのも、そのせいです。</p>
      <p>それから、ゲーム。よく遊ぶのはこのあたりです。</p>
      <ul class="games">
        <li v-for="game in games" :key="game.name">
          {{ game.name }}<small v-if="game.note">{{ game.note }}</small>
        </li>
      </ul>
    </section>

    <section class="block">
      <h2>道具</h2>
      <dl class="tools">
        <div v-for="tool in tools" :key="tool.kind">
          <dt>{{ tool.kind }}</dt>
          <dd>{{ tool.items }}</dd>
        </div>
      </dl>
    </section>

    <section class="block">
      <h2>この空について</h2>
      <p>
        背景の星は飾りではありません。約4万1千個の恒星を、実際の位置と明るさと色のまま、いまこの瞬間の向きで描いています。惑星と月も、いまの位置を計算して置いています。
      </p>
      <ul class="facts">
        <li>明るい星にカーソルを合わせる(スマホならタップする)と、名前と、その光がいつ星を出たのかがわかります。</li>
        <li>低い空の星ほどよく瞬きます。大気の中を長く通ってくるからです。惑星はほとんど瞬きません。</li>
        <li>開いた直後に明るい星しか見えないのは、目が暗さに慣れるまでのあの数秒を再現しているからです。</li>
        <li>天の川の模様と、遠くの稜線と、ときどき流れる流れ星だけは、つくりものです。</li>
      </ul>
      <p class="credit">
        恒星のデータはヒッパルコス星表(8等星まで)。<a href="https://github.com/ofrohn/d3-celestial">d3-celestial</a>
        に収録されたものを使っています。惑星と月の位置は
        <a href="https://github.com/cosinekitty/astronomy">Astronomy Engine</a> で計算しています。
      </p>
    </section>

    <footer class="block block--last">
      <h2>連絡先</h2>
      <ul class="links">
        <li v-for="link in links" :key="link.name">
          <a :href="link.url" rel="noopener">{{ link.name }}<small>{{ link.id }}</small></a>
        </li>
      </ul>
      <p class="credit">hayaa はハンドルネームです。</p>
    </footer>
  </main>
</template>
