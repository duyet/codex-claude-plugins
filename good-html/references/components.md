# Anthropic HTML Component Library

Use these components to build high-density, interactive artifacts. All components are self-contained and require only the base CSS variables defined in `boilerplate.html`.

## 1. Interactive Tabs (CSS-Only)
Uses the "Radio State Engine" for zero-JS interactivity.

```html
<style>
  .tabs { display: flex; flex-direction: column; }
  .tabs-nav { display: flex; gap: 4px; border-bottom: 1px solid var(--g200); margin-bottom: 20px; }
  .tabs-nav label {
    padding: 8px 16px; cursor: pointer; border-radius: 6px 6px 0 0;
    font-size: 14px; font-weight: 500; color: var(--g500); transition: 150ms;
  }
  .tabs-nav label:hover { background: var(--g100); color: var(--slate); }
  .tab-content { display: none; }

  #tab1:checked ~ .tabs-nav label[for="tab1"],
  #tab2:checked ~ .tabs-nav label[for="tab2"] {
    background: var(--paper); color: var(--clay); border: 1px solid var(--g200); border-bottom-color: var(--paper); margin-bottom: -1px;
  }

  #tab1:checked ~ #content1,
  #tab2:checked ~ #content2 { display: block; }
</style>

<div class="tabs">
  <input type="radio" id="tab1" name="tabs" checked hidden>
  <input type="radio" id="tab2" name="tabs" hidden>
  <div class="tabs-nav">
    <label for="tab1">Overview</label>
    <label for="tab2">Details</label>
  </div>
  <div id="content1" class="tab-content">Tab 1 Content</div>
  <div id="content2" class="tab-content">Tab 2 Content</div>
</div>
```

## 2. Code Diff Viewer
Optimized for PR reviews.

```html
<style>
  .diff-block { font-family: var(--mono); font-size: 13px; border-radius: 8px; overflow: hidden; border: 1px solid var(--g300); }
  .diff-line { display: grid; grid-template-columns: 40px 1fr; border-bottom: 1px solid var(--g100); }
  .diff-num { background: var(--g100); color: var(--g500); text-align: right; padding-right: 8px; user-select: none; }
  .diff-content { padding-left: 12px; white-space: pre-wrap; }
  .diff-line.add { background: rgba(120, 140, 93, 0.1); }
  .diff-line.del { background: rgba(176, 74, 63, 0.1); }
  .diff-line.add .diff-num { background: rgba(120, 140, 93, 0.2); }
  .diff-line.del .diff-num { background: rgba(176, 74, 63, 0.2); }
</style>
```

## 3. Status Board (Kanban/Triage)
```html
<style>
  .board { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
  .column { background: var(--g100); border-radius: 12px; padding: 16px; }
  .column-title { font-size: 14px; font-weight: 600; text-transform: uppercase; margin-bottom: 16px; color: var(--g700); }
  .item { background: var(--paper); border: 1px solid var(--g300); border-radius: 8px; padding: 12px; margin-bottom: 12px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
</style>
```

## 4. JS Utility: Copy to Clipboard
Simple snippet for code blocks or prompt tuners.

```javascript
function copyText(id) {
  const text = document.getElementById(id).innerText;
  navigator.clipboard.writeText(text).then(() => {
    const btn = event.target;
    const original = btn.innerText;
    btn.innerText = 'Copied!';
    setTimeout(() => btn.innerText = original, 2000);
  });
}
```

## 5. Visual Timeline (Milestones)
```html
<style>
  .timeline { position: relative; padding: 20px 0; margin: 20px 0; }
  .timeline::before { content: ''; position: absolute; left: 20px; top: 0; bottom: 0; width: 2px; background: var(--g200); }
  .milestone { position: relative; padding-left: 50px; margin-bottom: 30px; }
  .milestone::after { content: ''; position: absolute; left: 16px; top: 4px; width: 10px; height: 10px; border-radius: 50%; background: var(--paper); border: 2px solid var(--clay); }
  .milestone.done::after { background: var(--olive); border-color: var(--olive); }
  .milestone-date { font-family: var(--mono); font-size: 12px; color: var(--g500); }
  .milestone-title { font-weight: 600; margin: 4px 0; }
</style>
```

## 6. Risk / Impact Matrix
```html
<style>
  .matrix { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1px; background: var(--g300); border: 1px solid var(--g300); border-radius: 8px; overflow: hidden; }
  .matrix-cell { background: var(--paper); padding: 12px; min-height: 80px; }
  .matrix-header { background: var(--g100); font-weight: 600; font-size: 12px; text-align: center; padding: 8px; }
  .cell-high { background: rgba(176, 74, 63, 0.05); }
  .cell-med { background: rgba(217, 119, 87, 0.05); }
  .cell-low { background: rgba(120, 140, 93, 0.05); }
</style>
```

## 7. Interactive SVG Flowchart
Use inline SVGs for diagrams. Add simple hover effects for interactivity.

```html
<svg viewBox="0 0 400 200" style="width:100%; height:auto;">
  <style>
    .node { fill: var(--paper); stroke: var(--g300); stroke-width: 1.5; transition: 150ms; cursor: pointer; }
    .node:hover { stroke: var(--clay); fill: var(--ivory); }
    .label { font-family: var(--mono); font-size: 12px; fill: var(--slate); pointer-events: none; text-anchor: middle; }
    .arrow { stroke: var(--g300); stroke-width: 1.5; fill: none; marker-end: url(#arrowhead); }
  </style>
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="0" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="var(--g300)" />
    </marker>
  </defs>
  <rect x="50" y="70" width="100" height="40" rx="6" class="node" />
  <text x="100" y="95" class="label">Input</text>
  <line x1="150" y1="90" x2="240" y2="90" class="arrow" />
  <rect x="250" y="70" width="100" height="40" rx="6" class="node" />
  <text x="300" y="95" class="label">Process</text>
</svg>
```

## 9. Slide Deck (Full-screen Sections)
```html
<style>
  .slide-container { height: 100vh; overflow-y: scroll; scroll-snap-type: y mandatory; }
  .slide { height: 100vh; scroll-snap-align: start; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 40px; }
  .slide h1 { font-size: 64px; text-align: center; }
</style>
```

## 11. Sidebar Navigation (Multi-Page Artifacts)
Uses radio buttons for switching between "pages" within a single HTML file.

```html
<style>
  .app-container { display: flex; height: 100vh; }
  .sidebar { width: 240px; background: var(--g100); border-right: 1px solid var(--g200); padding: 20px; }
  .content-area { flex: 1; overflow-y: auto; padding: 40px; }
  
  .nav-item { display: block; padding: 10px 16px; border-radius: 8px; cursor: pointer; color: var(--g500); margin-bottom: 4px; }
  .nav-item:hover { background: var(--g200); color: var(--slate); }

  #page1:checked ~ .app-container label[for="page1"],
  #page2:checked ~ .app-container label[for="page2"] {
    background: var(--paper); color: var(--clay); box-shadow: 0 2px 4px rgba(0,0,0,0.05);
  }

  .page-view { display: none; }
  #page1:checked ~ .app-container #view1,
  #page2:checked ~ .app-container #view2 { display: block; }
</style>

<input type="radio" id="page1" name="nav" checked hidden>
<input type="radio" id="page2" name="nav" hidden>

<div class="app-container">
  <div class="sidebar">
    <label for="page1" class="nav-item">Dashboard</label>
    <label for="page2" class="nav-item">Settings</label>
  </div>
  <div class="content-area">
    <div id="view1" class="page-view"><h1>Dashboard</h1></div>
    <div id="view2" class="page-view"><h1>Settings</h1></div>
  </div>
</div>
```

