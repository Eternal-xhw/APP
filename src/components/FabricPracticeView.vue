<script setup>
import { onBeforeUnmount, onMounted, ref } from "vue";
import { f7 } from "framework7-vue";
import { Canvas, Line, Rect, Text, Textbox } from "fabric";

const canvasEl = ref(null);
const canvasWrapEl = ref(null);

let canvas = null;
let resizeObserver = null;
const modules = new Map();
let isPlaying = false;

const LAYOUT = {
  side: 20,
  top: 58,
  rowGap: 12,
  colGap: 24,
  cardHeight: 72,
  count: 8,
  bottomPadding: 24,
};

const FLOW_COLORS = {
  user: "#4f6ea8",
  data: "#2d8a63",
};

const TWO_COLUMN_BREAKPOINT = 520;

const calcCanvasHeight = (width) => {
  const useTwoCols = width >= TWO_COLUMN_BREAKPOINT;
  const rows = useTwoCols ? Math.ceil(LAYOUT.count / 2) : LAYOUT.count;
  const contentHeight =
    LAYOUT.top +
    26 + // 标题偏移
    rows * LAYOUT.cardHeight +
    (rows - 1) * LAYOUT.rowGap +
    LAYOUT.bottomPadding;
  return Math.max(420, contentHeight);
};

const getLayout = (width) => {
  const columns = width >= TWO_COLUMN_BREAKPOINT ? 2 : 1;
  const rawCardWidth =
    columns === 2
      ? Math.max(180, (width - LAYOUT.side * 2 - LAYOUT.colGap) / 2)
      : Math.max(180, width - LAYOUT.side * 2);
  const cardWidth = Math.round(rawCardWidth);

  const place = (index) => {
    if (columns === 2) {
      const col = index < 4 ? 0 : 1;
      const row = index % 4;
      return {
        left: Math.round(LAYOUT.side + col * (cardWidth + LAYOUT.colGap)),
        top: Math.round(LAYOUT.top + 26 + row * (LAYOUT.cardHeight + LAYOUT.rowGap)), // 增加26像素偏移给标题
      };
    }

    return {
      left: Math.round(LAYOUT.side),
      top: Math.round(LAYOUT.top + 26 + index * (LAYOUT.cardHeight + LAYOUT.rowGap)), // 增加26像素偏移给标题
    };
  };
  return { cardWidth, cardHeight: LAYOUT.cardHeight, place, columns };
};

const resizeCanvas = () => {
  if (!canvas || !canvasWrapEl.value) return;
  const width = canvasWrapEl.value.clientWidth;
  const height = calcCanvasHeight(width);
  canvas.setDimensions({ width, height });
  canvas.setViewportTransform([1, 0, 0, 1, 0, 0]);
  drawProjectDemo();
  canvas.requestRenderAll();
};

const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

const createModule = (key, title, desc, left, top, color, cardWidth, cardHeight) => {
  const contentLeft = Math.round(left + 14);
  const contentWidth = Math.round(cardWidth - 66);

  const box = new Rect({
    left,
    top,
    width: cardWidth,
    height: cardHeight,
    rx: 14,
    ry: 14,
    fill: color,
    stroke: "#404a5c",
    strokeWidth: 1.2,
    originX: "left",
    originY: "top",
    objectCaching: false,
  });

  const titleText = new Textbox(title, {
    left: contentLeft,
    top: top + 11,
    width: contentWidth,
    fontSize: 14,
    fontWeight: "700",
    fill: "#1f2430",
    fontFamily: "PingFang SC, Microsoft YaHei, sans-serif",
    originX: "left",
    originY: "top",
    editable: false,
    splitByGrapheme: true,
    selectable: false,
    evented: false,
    objectCaching: false,
  });

  const descText = new Textbox(desc, {
    left: contentLeft,
    top: top + 41,
    width: contentWidth,
    fontSize: 11,
    fill: "#495266",
    fontFamily: "PingFang SC, Microsoft YaHei, sans-serif",
    originX: "left",
    originY: "top",
    editable: false,
    splitByGrapheme: true,
    selectable: false,
    evented: true,
    objectCaching: false,
  });

  const phaseText = new Text(Number(key.order).toString().padStart(2, "0"), {
    left: Math.round(left + cardWidth - 38),
    top: top + 11,
    fontSize: 11,
    fontWeight: "700",
    fill: "#ffffff",
    fontFamily: "PingFang SC, Microsoft YaHei, sans-serif",
    selectable: false,
    evented: false,
    objectCaching: false,
  });

  const phaseBadge = new Rect({
    left: Math.round(left + cardWidth - 48),
    top: top + 9,
    width: 34,
    height: 22,
    rx: 11,
    ry: 11,
    fill: key.flow === "user" ? "#4f6ea8" : "#2d8a63",
    selectable: false,
    evented: false,
    objectCaching: false,
  });

  box.data = { key: key.id, title, desc };
  modules.set(key.id, box);
  return { box, titleText, descText, phaseBadge, phaseText };
};

const connectModules = (fromKey, toKey, flow = "user") => {
  if (!canvas) return;
  const from = modules.get(fromKey);
  const to = modules.get(toKey);
  if (!from || !to) return;

  const startX = Math.round(from.left + from.width / 2);
  const startY = Math.round(from.top + from.height);
  const endX = Math.round(to.left + to.width / 2);
  const endY = Math.round(to.top);

  const line = new Line([startX, startY, endX, endY], {
    stroke: flow === "user" ? FLOW_COLORS.user : FLOW_COLORS.data,
    strokeWidth: 2,
    strokeDashArray: flow === "data" ? [6, 4] : undefined,
    selectable: false,
    evented: false,
  });
  canvas.add(line);
};

const highlightModule = async (key, duration = 520) => {
  const module = modules.get(key);
  if (!module) return;
  const original = module.fill;
  module.set("fill", "#ffd56b");
  canvas.requestRenderAll();
  await wait(duration);
  module.set("fill", original);
  canvas.requestRenderAll();
};

const playUserFlow = async () => {
  if (!canvas || isPlaying) return;
  isPlaying = true;
  const flow = ["home", "search", "detail", "history"];
  for (const key of flow) {
    await highlightModule(key);
  }
  isPlaying = false;
  f7.toast.show({ text: "已完成用户访问路径演示" });
};

const playDataFlow = async () => {
  if (!canvas || isPlaying) return;
  isPlaying = true;
  const flow = ["follow", "setting", "api", "user"];
  for (const key of flow) {
    await highlightModule(key);
  }
  isPlaying = false;
  f7.toast.show({ text: "已完成数据与配置链路演示" });
};

const drawProjectDemo = () => {
  if (!canvas) return;

  const width = canvas.getWidth();
  const layout = getLayout(width);
  canvas.clear();
  modules.clear();
  canvas.backgroundColor = "#ffffff";

  const panelBg = new Rect({
    left: 10,
    top: 10,
    width: width - 20,
    height: canvas.getHeight() - 20,
    rx: 14,
    ry: 14,
    fill: "#f6f8fc",
    stroke: "#d7dfea",
    strokeWidth: 1,
    selectable: false,
    evented: false,
  });
  canvas.add(panelBg);

  const colWidth = layout.cardWidth + 16;
  const sectionHeight = 4 * LAYOUT.cardHeight + 3 * LAYOUT.rowGap + 26;
  const sectionTop = 18;

  // 左侧区域背景
  const leftSectionLeft = LAYOUT.side - 8;
  const leftSection = new Rect({
    left: leftSectionLeft,
    top: sectionTop,
    width: colWidth,
    height: sectionHeight,
    rx: 12,
    ry: 12,
    fill: "#edf3ff",
    stroke: "#d4dff2",
    strokeWidth: 1,
    selectable: false,
    evented: false,
  });

  // 右侧区域背景
  const rightSectionLeft = layout.columns === 2 
    ? (LAYOUT.side + layout.cardWidth + LAYOUT.colGap - 8) 
    : leftSectionLeft;
  const rightSectionTop = layout.columns === 2 
    ? sectionTop 
    : (sectionTop + sectionHeight + 10);
  
  const rightSection = new Rect({
    left: rightSectionLeft,
    top: rightSectionTop,
    width: colWidth,
    height: sectionHeight,
    rx: 12,
    ry: 12,
    fill: "#eef8f2",
    stroke: "#d3e7db",
    strokeWidth: 1,
    selectable: false,
    evented: false,
  });

  canvas.add(leftSection, rightSection);

  // 用户触点标题
  const sectionUser = new Text("用户触点", {
    left: leftSectionLeft + 8,
    top: sectionTop + 8,
    fontSize: 13,
    fontWeight: "700",
    fill: "#4f6ea8",
    fontFamily: "PingFang SC, Microsoft YaHei, sans-serif",
    selectable: false,
    evented: false,
    objectCaching: false,
  });
  
  // 系统能力标题
  const sectionSystem = new Text("系统能力", {
    left: rightSectionLeft + 8,
    top: rightSectionTop + 8,
    fontSize: 13,
    fontWeight: "700",
    fill: "#2d8a63",
    fontFamily: "PingFang SC, Microsoft YaHei, sans-serif",
    selectable: false,
    evented: false,
    objectCaching: false,
  });
  canvas.add(sectionUser, sectionSystem);

  const items = [
    {
      id: "home",
      order: 1,
      flow: "user",
      title: "首页",
      desc: "推荐/想法/热榜",
      color: "#dce8fb",
    },
    {
      id: "search",
      order: 2,
      flow: "user",
      title: "搜索页",
      desc: "建议/结果/跳转",
      color: "#e8effd",
    },
    {
      id: "detail",
      order: 3,
      flow: "user",
      title: "详情页",
      desc: "问题/文章/用户",
      color: "#e4ecff",
    },
    {
      id: "history",
      order: 4,
      flow: "user",
      title: "历史记录",
      desc: "浏览轨迹恢复",
      color: "#eaf1ff",
    },
    {
      id: "follow",
      order: 5,
      flow: "data",
      title: "关注页",
      desc: "动态与关系流",
      color: "#dff3e7",
    },
    {
      id: "setting",
      order: 6,
      flow: "data",
      title: "设置页",
      desc: "主题/入口管理",
      color: "#e6f5eb",
    },
    {
      id: "api",
      order: 7,
      flow: "data",
      title: "API 层",
      desc: "auth/http/request",
      color: "#e2f4ea",
    },
    {
      id: "user",
      order: 8,
      flow: "data",
      title: "用户状态",
      desc: "store/userManager",
      color: "#e7f6ec",
    },
  ].map((item, index) => {
    const pos = layout.place(index);
    return createModule(
      item,
      item.title,
      item.desc,
      pos.left,
      pos.top,
      item.color,
      layout.cardWidth,
      layout.cardHeight,
    );
  });

  // 先添加所有模块
  items.forEach((item) => {
    canvas.add(item.box);
    canvas.add(item.phaseBadge);
    canvas.add(item.phaseText);
    canvas.add(item.titleText);
    canvas.add(item.descText);
  });

  // 后添加连接线
  connectModules("home", "search", "user");
  connectModules("search", "detail", "user");
  connectModules("detail", "history", "user");

  connectModules("follow", "setting", "data");
  connectModules("setting", "api", "data");
  connectModules("api", "user", "data");

  // 确保模块在顶层
  items.forEach((item) => {
    item.box.bringToFront();
    item.phaseBadge.bringToFront();
    item.phaseText.bringToFront();
    item.titleText.bringToFront();
    item.descText.bringToFront();
  });

  canvas.requestRenderAll();
};

const resetDemo = () => {
  drawProjectDemo();
  f7.toast.show({ text: "演示图已重置" });
};

const exportPng = () => {
  if (!canvas) return;
  const dataUrl = canvas.toDataURL({ format: "png", multiplier: 2 });
  const win = window.open("about:blank", "_blank");
  if (!win) {
    f7.toast.show({ text: "浏览器拦截了新窗口，请允许弹窗后重试" });
    return;
  }
  win.document.write(
    `<img src="${dataUrl}" alt="fabric-canvas" style="max-width:100%;height:auto;display:block;" />`,
  );
  win.document.close();
};

onMounted(() => {
  if (!canvasEl.value) return;
  f7.dialog.close();
  canvas = new Canvas(canvasEl.value, {
    backgroundColor: "#ffffff",
    preserveObjectStacking: true,
    enableRetinaScaling: true,
  });

  resizeCanvas();

  canvas.on("mouse:down", (event) => {
    const item = event.target;
    if (item && item.data?.title) {
      f7.toast.show({ text: `${item.data.title}: ${item.data.desc}` });
    }
  });

  if (canvasWrapEl.value) {
    resizeObserver = new ResizeObserver(() => {
      resizeCanvas();
    });
    resizeObserver.observe(canvasWrapEl.value);
  }

  requestAnimationFrame(() => {
    resizeCanvas();
  });
});

onBeforeUnmount(() => {
  if (resizeObserver) {
    resizeObserver.disconnect();
    resizeObserver = null;
  }
  if (canvas) {
    canvas.dispose();
    canvas = null;
  }
});
</script>

<template>
  <f7-page name="fabric-practice">
    <f7-navbar title="Fabric 项目演示" back-link="返回" />

    <f7-block strong inset>
      <p class="margin-top-half margin-bottom-half">
        使用 Fabric.js
        可视化该项目的页面模块与数据链路，支持流程演示与导出。
      </p>
      <div class="toolbar-grid">
        <f7-button small fill @click="playUserFlow">播放用户路径</f7-button>
        <f7-button small fill @click="playDataFlow">播放数据链路</f7-button>
        <f7-button small outline color="red" @click="resetDemo"
          >重置图谱</f7-button
        >
      </div>
      <div class="margin-top">
        <f7-button large fill color="green" @click="exportPng"
          >导出 PNG 预览</f7-button
        >
      </div>
    </f7-block>

    <f7-block strong inset>
      <div ref="canvasWrapEl" class="canvas-wrap">
        <canvas ref="canvasEl"></canvas>
      </div>
    </f7-block>
  </f7-page>
</template>

<style scoped>
.toolbar-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 8px;
}

.canvas-wrap {
  border: 1px solid var(--f7-list-item-border-color);
  border-radius: 10px;
  overflow: hidden;
  background: #fff;
  width: 100%;
}

.canvas-wrap canvas {
  display: block;
  width: 100% !important;
  height: auto !important;
}
</style>
