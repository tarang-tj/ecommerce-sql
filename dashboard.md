
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { font-family: var(--font-sans); color: var(--color-text-primary); }
  .dash { padding: 1rem 0; }
  .section-title { font-size: 13px; font-weight: 500; color: var(--color-text-secondary); text-transform: uppercase; letter-spacing: .06em; margin-bottom: 12px; margin-top: 24px; }
  .metrics { display: grid; grid-template-columns: repeat(4, minmax(0,1fr)); gap: 10px; margin-bottom: 8px; }
  .metric { background: var(--color-background-secondary); border-radius: var(--border-radius-md); padding: 14px 16px; }
  .metric-label { font-size: 12px; color: var(--color-text-secondary); margin-bottom: 4px; }
  .metric-value { font-size: 22px; font-weight: 500; }
  .metric-sub { font-size: 11px; color: var(--color-text-tertiary); margin-top: 2px; }
  .panels { display: grid; grid-template-columns: minmax(0,1.4fr) minmax(0,1fr); gap: 16px; margin-top: 8px; }
  .panel { background: var(--color-background-primary); border: 0.5px solid var(--color-border-tertiary); border-radius: var(--border-radius-lg); padding: 16px; }
  .panel-title { font-size: 13px; font-weight: 500; margin-bottom: 14px; }
  .tabs { display: flex; gap: 4px; margin-bottom: 16px; }
  .tab { font-size: 12px; padding: 5px 12px; border-radius: 99px; cursor: pointer; border: 0.5px solid var(--color-border-tertiary); background: transparent; color: var(--color-text-secondary); transition: all .15s; }
  .tab.active { background: var(--color-text-primary); color: var(--color-background-primary); border-color: transparent; }
  .bar-row { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; font-size: 12px; }
  .bar-label { width: 90px; color: var(--color-text-secondary); text-align: right; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .bar-track { flex: 1; height: 8px; background: var(--color-background-secondary); border-radius: 4px; overflow: hidden; }
  .bar-fill { height: 100%; border-radius: 4px; transition: width .5s cubic-bezier(.4,0,.2,1); }
  .bar-val { width: 54px; color: var(--color-text-primary); font-weight: 500; text-align: right; }
  .erd { width: 100%; overflow-x: auto; }
  .legend { display: flex; flex-wrap: wrap; gap: 12px; font-size: 11px; color: var(--color-text-secondary); margin-bottom: 10px; }
  .legend-dot { width: 10px; height: 10px; border-radius: 2px; display: inline-block; margin-right: 4px; }
  .order-row { display: flex; align-items: center; justify-content: space-between; padding: 7px 0; border-bottom: 0.5px solid var(--color-border-tertiary); font-size: 12px; }
  .order-row:last-child { border-bottom: none; }
  .badge { font-size: 10px; padding: 2px 8px; border-radius: 99px; font-weight: 500; }
  .badge-delivered { background: var(--color-background-success); color: var(--color-text-success); }
  .badge-shipped   { background: var(--color-background-info);    color: var(--color-text-info); }
  .badge-pending   { background: var(--color-background-warning);  color: var(--color-text-warning); }
  .badge-cancelled { background: var(--color-background-danger);   color: var(--color-text-danger); }
  .chart-wrap { position: relative; width: 100%; height: 180px; }
  .full-panel { background: var(--color-background-primary); border: 0.5px solid var(--color-border-tertiary); border-radius: var(--border-radius-lg); padding: 16px; margin-top: 16px; }
</style>

<div class="dash">

  <div class="metrics">
    <div class="metric">
      <div class="metric-label">Total revenue</div>
      <div class="metric-value">$10,779</div>
      <div class="metric-sub">excl. cancellations</div>
    </div>
    <div class="metric">
      <div class="metric-label">Total orders</div>
      <div class="metric-value">9</div>
      <div class="metric-sub">1 cancelled</div>
    </div>
    <div class="metric">
      <div class="metric-label">Avg. order value</div>
      <div class="metric-value">$1,197</div>
      <div class="metric-sub">delivered + shipped</div>
    </div>
    <div class="metric">
      <div class="metric-label">Customers</div>
      <div class="metric-value">8</div>
      <div class="metric-sub">3 repeat buyers</div>
    </div>
  </div>

  <div class="panels">
    <!-- LEFT: bar charts with tabs -->
    <div class="panel">
      <div class="panel-title">Performance breakdown</div>
      <div class="tabs">
        <button class="tab active" onclick="showTab('products')">Products</button>
        <button class="tab" onclick="showTab('categories')">Categories</button>
        <button class="tab" onclick="showTab('customers')">Customers</button>
      </div>
      <div id="tab-products"></div>
      <div id="tab-categories" style="display:none"></div>
      <div id="tab-customers" style="display:none"></div>
    </div>

    <!-- RIGHT: order status + monthly trend -->
    <div class="panel">
      <div class="panel-title">Order status</div>
      <div id="status-bars"></div>
      <div style="margin-top:16px; padding-top:14px; border-top: 0.5px solid var(--color-border-tertiary);">
        <div class="panel-title">Recent orders</div>
        <div id="recent-orders"></div>
      </div>
    </div>
  </div>

  <!-- ERD + Monthly Revenue -->
  <div class="panels" style="margin-top:16px;">
    <!-- Monthly revenue chart -->
    <div class="panel">
      <div class="panel-title">Monthly revenue trend</div>
      <div class="chart-wrap"><canvas id="revChart"></canvas></div>
    </div>
    <!-- ERD -->
    <div class="panel">
      <div class="panel-title">Schema — entity relationships</div>
      <div class="erd">
        <svg width="100%" viewBox="0 0 320 270" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <marker id="arr2" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" orient="auto-start-reverse">
              <path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
            </marker>
          </defs>
          <!-- customers -->
          <g class="c-purple">
            <rect x="10" y="10" width="90" height="32" rx="6" stroke-width="0.5"/>
            <text style="font-size:11px;font-weight:500" x="55" y="30" text-anchor="middle" dominant-baseline="central">customers</text>
          </g>
          <!-- orders -->
          <g class="c-teal">
            <rect x="115" y="10" width="90" height="32" rx="6" stroke-width="0.5"/>
            <text style="font-size:11px;font-weight:500" x="160" y="30" text-anchor="middle" dominant-baseline="central">orders</text>
          </g>
          <!-- order_items -->
          <g class="c-teal">
            <rect x="115" y="80" width="90" height="32" rx="6" stroke-width="0.5"/>
            <text style="font-size:11px;font-weight:500" x="160" y="96" text-anchor="middle" dominant-baseline="central">order_items</text>
          </g>
          <!-- products -->
          <g class="c-amber">
            <rect x="220" y="80" width="90" height="32" rx="6" stroke-width="0.5"/>
            <text style="font-size:11px;font-weight:500" x="265" y="96" text-anchor="middle" dominant-baseline="central">products</text>
          </g>
          <!-- categories -->
          <g class="c-amber">
            <rect x="220" y="150" width="90" height="32" rx="6" stroke-width="0.5"/>
            <text style="font-size:11px;font-weight:500" x="265" y="166" text-anchor="middle" dominant-baseline="central">categories</text>
          </g>
          <!-- reviews -->
          <g class="c-coral">
            <rect x="10" y="150" width="90" height="32" rx="6" stroke-width="0.5"/>
            <text style="font-size:11px;font-weight:500" x="55" y="166" text-anchor="middle" dominant-baseline="central">reviews</text>
          </g>
          <!-- connectors -->
          <line x1="100" y1="26" x2="113" y2="26" stroke="var(--color-border-secondary)" stroke-width="1" marker-end="url(#arr2)"/>
          <line x1="160" y1="42" x2="160" y2="78" stroke="var(--color-border-secondary)" stroke-width="1" marker-end="url(#arr2)"/>
          <line x1="205" y1="96" x2="218" y2="96" stroke="var(--color-border-secondary)" stroke-width="1" marker-end="url(#arr2)"/>
          <line x1="265" y1="112" x2="265" y2="148" stroke="var(--color-border-secondary)" stroke-width="1" marker-end="url(#arr2)"/>
          <!-- customers → reviews -->
          <path d="M55 42 L55 148" fill="none" stroke="var(--color-border-secondary)" stroke-width="1" stroke-dasharray="3 3" marker-end="url(#arr2)"/>
          <!-- products → reviews -->
          <path d="M230 112 L100 158" fill="none" stroke="var(--color-border-secondary)" stroke-width="1" stroke-dasharray="3 3" marker-end="url(#arr2)"/>
          <!-- edge labels -->
          <text style="font-size:9px" x="105" y="22" fill="var(--color-text-tertiary)">1:N</text>
          <text style="font-size:9px" x="163" y="65" fill="var(--color-text-tertiary)">1:N</text>
          <text style="font-size:9px" x="208" y="92" fill="var(--color-text-tertiary)">1:N</text>
          <text style="font-size:9px" x="268" y="135" fill="var(--color-text-tertiary)">1:N</text>
          <!-- legend -->
          <g class="c-purple"><rect x="10" y="220" width="10" height="10" rx="2" stroke-width="0"/></g>
          <text style="font-size:9px" x="24" y="229" fill="var(--color-text-secondary)">users</text>
          <g class="c-teal"><rect x="60" y="220" width="10" height="10" rx="2" stroke-width="0"/></g>
          <text style="font-size:9px" x="74" y="229" fill="var(--color-text-secondary)">orders</text>
          <g class="c-amber"><rect x="118" y="220" width="10" height="10" rx="2" stroke-width="0"/></g>
          <text style="font-size:9px" x="132" y="229" fill="var(--color-text-secondary)">catalogue</text>
          <g class="c-coral"><rect x="192" y="220" width="10" height="10" rx="2" stroke-width="0"/></g>
          <text style="font-size:9px" x="206" y="229" fill="var(--color-text-secondary)">engagement</text>
          <text style="font-size:9px" x="10" y="250" fill="var(--color-text-tertiary)">— — dashed = optional relationship</text>
        </svg>
      </div>
    </div>
  </div>

</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.js"></script>
<script>
const products = [
  { name: 'MacBook Pro 14"', revenue: 3999.98, units: 2 },
  { name: 'iPhone 15 Pro',   revenue: 2999.97, units: 3 },
  { name: 'Samsung S24',     revenue: 1699.98, units: 2 },
  { name: 'Dell XPS 15',     revenue: 1499.99, units: 1 },
  { name: "Women's Sneakers",revenue: 269.97,  units: 3 },
  { name: 'Clean Code',      revenue: 174.95,  units: 5 },
];
const categories = [
  { name: 'Laptops',     revenue: 5499.97 },
  { name: 'Phones',      revenue: 4699.95 },
  { name: "Women's",     revenue: 269.97  },
  { name: 'Books',       revenue: 209.95  },
  { name: "Men's",       revenue: 119.98  },
];
const customers = [
  { name: 'Alice J.',   ltv: 3034.97 },
  { name: 'Hannah M.',  ltv: 1999.99 },
  { name: 'Fiona W.',   ltv: 1999.99 },
  { name: 'Bob S.',     ltv: 889.98  },
  { name: 'Carlos D.',  ltv: 889.98  },
  { name: 'Diana L.',   ltv: 89.99   },
];
const statusData = [
  { label: 'Delivered', count: 7, cls: 'badge-delivered', color: '#1D9E75' },
  { label: 'Shipped',   count: 1, cls: 'badge-shipped',   color: '#378ADD' },
  { label: 'Pending',   count: 1, cls: 'badge-pending',   color: '#BA7517' },
  { label: 'Cancelled', count: 1, cls: 'badge-cancelled', color: '#E24B4A' },
];
const recentOrders = [
  { id: '#010', customer: 'Alice J.',  total: '$1,029.98', status: 'delivered' },
  { id: '#009', customer: 'Hannah M.', total: '$1,999.99', status: 'delivered' },
  { id: '#008', customer: 'Fiona W.',  total: '$1,999.99', status: 'delivered' },
  { id: '#007', customer: 'George T.', total: '$1,999.98', status: 'pending'   },
  { id: '#006', customer: 'Ethan B.',  total: '$1,499.99', status: 'cancelled' },
];
const monthly = [
  { m: 'Jan', rev: 1089.98 },
  { m: 'Feb', rev: 2034.98 },
  { m: 'Mar', rev: 2034.97 },
  { m: 'Apr', rev: 4329.94 },
  { m: 'May', rev: 1029.98 },
];

function barColor(i) {
  return ['#534AB7','#0F6E56','#993C1D','#185FA5','#3B6D11','#854F0B'][i % 6];
}

function renderBars(containerId, data, keyLabel, keyVal, fmt) {
  const max = Math.max(...data.map(d => d[keyVal]));
  const el = document.getElementById(containerId);
  el.innerHTML = data.map((d, i) => `
    <div class="bar-row">
      <div class="bar-label" title="${d[keyLabel]}">${d[keyLabel]}</div>
      <div class="bar-track">
        <div class="bar-fill" style="width:${(d[keyVal]/max*100).toFixed(1)}%;background:${barColor(i)}"></div>
      </div>
      <div class="bar-val">${fmt(d[keyVal])}</div>
    </div>`).join('');
}

function showTab(name) {
  ['products','categories','customers'].forEach(t => {
    document.getElementById('tab-'+t).style.display = t === name ? '' : 'none';
    document.querySelectorAll('.tab').forEach((btn, i) => {
      btn.classList.toggle('active', ['products','categories','customers'][i] === name);
    });
  });
}

const usd = v => '$' + v.toLocaleString('en-US', {maximumFractionDigits:0});
renderBars('tab-products',   products,   'name', 'revenue', usd);
renderBars('tab-categories', categories, 'name', 'revenue', usd);
renderBars('tab-customers',  customers,  'name', 'ltv',     usd);

const total = statusData.reduce((s,d) => s + d.count, 0);
document.getElementById('status-bars').innerHTML = statusData.map(s => `
  <div class="bar-row">
    <div class="bar-label">${s.label}</div>
    <div class="bar-track">
      <div class="bar-fill" style="width:${(s.count/total*100).toFixed(1)}%;background:${s.color}"></div>
    </div>
    <div class="bar-val">${s.count} <span style="color:var(--color-text-tertiary);font-weight:400">(${Math.round(s.count/total*100)}%)</span></div>
  </div>`).join('');

document.getElementById('recent-orders').innerHTML = recentOrders.map(o => `
  <div class="order-row">
    <span style="font-weight:500;color:var(--color-text-secondary)">${o.id}</span>
    <span>${o.customer}</span>
    <span>${o.total}</span>
    <span class="badge badge-${o.status}">${o.status}</span>
  </div>`).join('');

const isDark = matchMedia('(prefers-color-scheme: dark)').matches;
new Chart(document.getElementById('revChart'), {
  type: 'bar',
  data: {
    labels: monthly.map(d => d.m),
    datasets: [{
      label: 'Revenue',
      data: monthly.map(d => d.rev),
      backgroundColor: isDark ? '#534AB7' : '#7F77DD',
      borderRadius: 4,
      borderSkipped: false,
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { display: false }, ticks: { color: isDark ? '#888780' : '#5F5E5A', font: { size: 11 } } },
      y: {
        grid: { color: isDark ? 'rgba(255,255,255,.06)' : 'rgba(0,0,0,.06)' },
        ticks: { color: isDark ? '#888780' : '#5F5E5A', font: { size: 11 }, callback: v => '$' + (v/1000).toFixed(1) + 'k' }
      }
    }
  }
});
</script>
