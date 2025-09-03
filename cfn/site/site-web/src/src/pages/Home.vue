<script setup>
import axios from "axios"
import { Map } from "maplibre-gl"
import { onMounted, ref, toValue, useTemplateRef, watch } from "vue"

import { useAuth } from "../plugins/auth/index.js"

const { getToken, user } = useAuth()

const name = ref("")
const container = useTemplateRef("container")

const stop = watch(container, async (container) => {
  if (!container) {
    return
  }
  stop()

  const map = new Map({
    container,
    style: "https://tile.openstreetmap.jp/styles/maptiler-basic-ja/style.json",
    center: { lng: 139.75, lat: 35.691667 },
    zoom: 7,
  })
  await map.once("load")

  map.addSource("wx_report", { type: "geojson", data: "/json/wx_report/latest.geojson" })
  map.addLayer({
    id: "wx_report",
    type: "circle",
    source: "wx_report",
    paint: {
      "circle-radius": ["interpolate", ["linear"], ["zoom"], 5, 3, 9, 6],
      "circle-stroke-width": ["interpolate", ["linear"], ["zoom"], 5, 0.3, 9, 1],
      "circle-color": [
        "match",
        ["get", "wx"],
        100,
        "#DE5800",
        101,
        "#E99B02",
        200,
        "#A4A4A4",
        300,
        "#A1E5CB",
        301,
        "#44D5E6",
        302,
        "#007CCC",
        303,
        "#0400CB",
        304,
        "#E1E117",
        400,
        "#CE99CD",
        410,
        "#F1F1F1",
        411,
        "#F1F1F1",
        412,
        "#F1F1F1",
        420,
        "#000000",
        421,
        "#8F30BD",
        422,
        "#EA0E87",
        "rgba(0, 0, 0, 0)",
      ],
      "circle-stroke-color": "#FFFFFF",
    },
  })
})

onMounted(async () => {
  const config = {
    headers: { Authorization: `Bearer ${await getToken()}` },
    validateStatus: (status) => status >= 200 && status < 500,
  }
  const { data } = await axios.get(`/customer/${toValue(user).customer_ids.at(0)}/config.json`, config)
  name.value = data.name
})
</script>

<template>
  <div class="relative">
    <div class="h-full" ref="container"></div>
    <div class="absolute top-0 left-0 p-4 text-2xl">{{ name }}</div>
  </div>
</template>
