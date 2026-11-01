// ==========================================================================
// لوحة تحكم إدارة مطعم بيتزا أولاد الشيخ - Pizza Awlad Alsheikh Admin Logic
// صفحة مستقلة بالكامل لإدارة المنتجات، الأسعار، الطلبات، والإعدادات
// ==========================================================================

const adminState = {
  theme: localStorage.getItem('alsheikh_theme') || 'light',
  lang: localStorage.getItem('alsheikh_lang') || 'ar',
  isAuthenticated: sessionStorage.getItem('alsheikh_admin_auth') === 'true',
  currentView: 'orders', // 'overview' | 'orders' | 'products' | 'offers' | 'settings'
  products: [],
  offers: [],
  coupons: [],
  categories: DEFAULT_CATEGORIES,
  orders: [],
  settings: { ...DEFAULT_SETTINGS },
  ordersFilter: 'all',
  ordersSearch: '',
  productsFilter: 'all',
  productsSearch: '',
  editingProduct: null,
  editingOffer: null
};

// ==========================================
// 1. التهيئة والتحقق من تسجيل الدخول
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
  initAdminTheme();
  loadAdminData();
  populateCategoryDropdowns();
  checkAuth();
  setupAdminListeners();
});

function initAdminTheme() {
  document.documentElement.setAttribute('data-theme', adminState.theme);
  const themeBtn = document.getElementById('admin-theme-btn');
  if (themeBtn) {
    themeBtn.innerHTML = adminState.theme === 'dark' ? '<i class="fas fa-sun"></i>' : '<i class="fas fa-moon"></i>';
  }
}

function toggleAdminTheme() {
  adminState.theme = adminState.theme === 'dark' ? 'light' : 'dark';
  localStorage.setItem('alsheikh_theme', adminState.theme);
  initAdminTheme();
}

function checkAuth() {
  const loginWrapper = document.getElementById('login-wrapper');
  const mainWrapper = document.getElementById('admin-main-wrapper');

  if (adminState.isAuthenticated) {
    loginWrapper.style.display = 'none';
    mainWrapper.style.display = 'flex';
    switchAdminView(adminState.currentView);
    updateDashboardStats();
  } else {
    loginWrapper.style.display = 'flex';
    mainWrapper.style.display = 'none';
  }
}

function getAdminCredentials() {
  const saved = localStorage.getItem('alsheikh_admin_creds');
  if (saved) {
    try {
      return JSON.parse(saved);
    } catch (e) {}
  }
  return { username: 'admin', password: 'AdminPassword123!' };
}

function togglePasswordVisibility(fieldId, btn) {
  const input = document.getElementById(fieldId);
  if (!input) return;
  const isPass = input.type === 'password';
  input.type = isPass ? 'text' : 'password';
  const icon = btn.querySelector('i');
  if (icon) {
    icon.className = isPass ? 'fas fa-eye-slash' : 'fas fa-eye';
  }
}

function handleLoginSubmit(e) {
  e.preventDefault();
  const user = document.getElementById('login-username').value.trim();
  const pass = document.getElementById('login-password').value.trim();
  const creds = getAdminCredentials();

  // التحقق من بيانات الاعتماد المحدثة أو الافتراضية
  if (user === creds.username && pass === creds.password) {
    adminState.isAuthenticated = true;
    sessionStorage.setItem('alsheikh_admin_auth', 'true');
    checkAuth();
    showToast('مرحباً بك! تم تسجيل الدخول بنجاح إلى لوحة الإدارة.');
  } else {
    alert('اسم المستخدم أو كلمة المرور غير صحيحة! يرجى التحقق من البيانات.');
  }
}

function handleLogout() {
  if (confirm('هل أنت متأكد من رغبتك في تسجيل الخروج من لوحة الإدارة؟')) {
    adminState.isAuthenticated = false;
    sessionStorage.removeItem('alsheikh_admin_auth');
    checkAuth();
  }
}

// طلبات أولية لعرضها في لوحة التحكم عند عدم وجود طلبات مسجلة
const DEFAULT_ORDERS = [
  {
    orderRef: '#ORD-1001',
    customerName: 'أحمد محمود',
    customerPhone: '01112962692',
    orderType: 'delivery',
    area: 'إمبابة - شارع الوحدة',
    address: 'شارع الوحدة الرئيسي، بجوار البنك الأهلي، عمارة 4 الدور 2',
    locationUrl: 'https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6',
    items: [
      { name: 'بيتزا سوبر سوبريم', size: 'كبير', quantity: 1, price: 195, totalPrice: 195, extras: ['أطراف جبنة موتزاريلا'] },
      { name: 'كريب كرانشي دجاج', size: 'عادي', quantity: 2, price: 85, totalPrice: 170, extras: ['بطاطس مقلية إكسترا'] }
    ],
    total: 395,
    paymentMethod: 'الدفع عند الاستلام (كاش)',
    status: 'Preparing',
    instructions: 'يرجى الاتصال عند الوصول أسفل العمارة ولا داعي للشطة الحارة.',
    createdAt: new Date(Date.now() - 25 * 60 * 1000).toISOString()
  },
  {
    orderRef: '#ORD-1002',
    customerName: 'محمود عبد العزيز',
    customerPhone: '01012345678',
    orderType: 'takeaway',
    area: 'استلام مباشر من الفرع',
    address: 'فرع إمبابة - امتداد شارع الوحدة',
    locationUrl: '',
    items: [
      { name: 'فطيرة مشلتت بالسمن البلدي والقشطة والعسل', size: 'وسط', quantity: 1, price: 140, totalPrice: 140, extras: [] },
      { name: 'حواوشي أولاد الشيخ بالخلطة السرية', size: 'رغيف كبير', quantity: 2, price: 55, totalPrice: 110, extras: ['مخلل وطحينة'] }
    ],
    total: 250,
    paymentMethod: 'الدفع نقداً بالفرع',
    status: 'Confirmed',
    instructions: 'سأمر للاستلام خلال 20 دقيقة.',
    createdAt: new Date(Date.now() - 45 * 60 * 1000).toISOString()
  },
  {
    orderRef: '#ORD-1003',
    customerName: 'مريم السيد',
    customerPhone: '01223344556',
    orderType: 'delivery',
    area: 'المنيرة الغربية - شارع المطار',
    address: 'ميدان المطار، عمارة الأمل، الدور 5 شقة 9',
    locationUrl: 'https://maps.app.goo.gl/Hi55NFkp5H8ZNDqV6',
    items: [
      { name: 'بيتزا تشيكن رانش باربيكيو', size: 'وسط', quantity: 1, price: 165, totalPrice: 165, extras: ['صوص رانش إضافي'] }
    ],
    total: 190,
    paymentMethod: 'الدفع عند الاستلام (كاش)',
    status: 'OutForDelivery',
    instructions: 'الرجاء الاستعجال والتأكد من وصولها ساخنة.',
    createdAt: new Date(Date.now() - 70 * 60 * 1000).toISOString()
  }
];

// ==========================================
// 2. تحميل وحفظ البيانات (Data Management)
// ==========================================
function loadAdminData() {
  // تحميل المنتجات
  const savedProducts = localStorage.getItem('alsheikh_products');
  if (savedProducts) {
    try {
      adminState.products = JSON.parse(savedProducts);
    } catch (e) {
      adminState.products = [...DEFAULT_PRODUCTS];
    }
  } else {
    adminState.products = [...DEFAULT_PRODUCTS];
  }

  // تحميل العروض والخصومات
  const savedOffers = localStorage.getItem('alsheikh_offers');
  if (savedOffers) {
    try {
      adminState.offers = JSON.parse(savedOffers);
    } catch (e) {
      adminState.offers = [...DEFAULT_OFFERS];
    }
  } else {
    adminState.offers = [...DEFAULT_OFFERS];
  }

  // تحميل الكوبونات
  const savedCoupons = localStorage.getItem('alsheikh_coupons');
  if (savedCoupons) {
    try {
      adminState.coupons = JSON.parse(savedCoupons);
    } catch (e) {
      adminState.coupons = [...DEFAULT_COUPONS];
    }
  } else {
    adminState.coupons = [...DEFAULT_COUPONS];
  }

  // تحميل التصنيفات
  const savedCategories = localStorage.getItem('alsheikh_categories');
  if (savedCategories) {
    try {
      const parsedCats = JSON.parse(savedCategories);
      adminState.categories = Array.isArray(parsedCats) && parsedCats.length > 0 ? parsedCats : [...DEFAULT_CATEGORIES];
    } catch (e) {
      adminState.categories = [...DEFAULT_CATEGORIES];
    }
  } else {
    adminState.categories = [...DEFAULT_CATEGORIES];
  }

  // تحميل الطلبات (الحفاظ الدائم على تعديلات وحذف المستخدم حتى مع عمل Refresh)
  const savedOrders = localStorage.getItem('alsheikh_orders');
  if (savedOrders !== null) {
    try {
      const parsed = JSON.parse(savedOrders);
      adminState.orders = Array.isArray(parsed) ? parsed : [];
    } catch (e) {
      adminState.orders = [];
    }
  } else {
    // في حال عدم وجود أي سجل مسبقاً (زيارة جديدة تماماً)، يبدأ السجل نظيفاً وفارغاً
    adminState.orders = [];
    localStorage.setItem('alsheikh_orders', '[]');
  }

  // تحميل الإعدادات
  const savedSettings = localStorage.getItem('alsheikh_settings');
  if (savedSettings) {
    try {
      adminState.settings = { ...DEFAULT_SETTINGS, ...JSON.parse(savedSettings) };
    } catch (e) {
      adminState.settings = { ...DEFAULT_SETTINGS };
    }
  } else {
    adminState.settings = { ...DEFAULT_SETTINGS };
  }
}

function saveProducts() {
  localStorage.setItem('alsheikh_products', JSON.stringify(adminState.products));
  updateDashboardStats();
}

function saveCategories() {
  localStorage.setItem('alsheikh_categories', JSON.stringify(adminState.categories));
  populateCategoryDropdowns();
  renderCategoriesView();
  renderProductsTable();
}

function saveOffers() {
  localStorage.setItem('alsheikh_offers', JSON.stringify(adminState.offers));
  updateDashboardStats();
}

function saveCoupons() {
  localStorage.setItem('alsheikh_coupons', JSON.stringify(adminState.coupons));
}

function saveOrders() {
  localStorage.setItem('alsheikh_orders', JSON.stringify(adminState.orders));
  updateDashboardStats();
}

function saveSettings() {
  localStorage.setItem('alsheikh_settings', JSON.stringify(adminState.settings));
}

// ==========================================
// 3. التنقل بين التبويبات والمشاهد (Views)
// ==========================================
function switchAdminView(viewName) {
  adminState.currentView = viewName;
  closeAdminSidebar(); // إغلاق القائمة تلقائياً في الموبايل عند اختيار قسم

  // تحديث أزرار القائمة الجانبية
  document.querySelectorAll('.nav-item-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.view === viewName);
  });

  // إظهار القسم المطلوب
  document.querySelectorAll('.admin-view-pane').forEach(pane => {
    pane.classList.toggle('active', pane.id === `view-${viewName}`);
  });

  // تحديث العنوان العلوي
  const titles = {
    overview: 'نظرة عامة وإحصائيات المطعم',
    orders: 'إدارة ومتابعة طلبات العملاء',
    products: 'إدارة قائمة الطعام والأسعار',
    categories: 'إدارة وتخصيص تصنيفات المنيو',
    offers: 'إدارة العروض والخصومات والكوبونات',
    settings: 'إعدادات المطعم وبيانات الاتصال'
  };
  const topTitle = document.getElementById('topbar-view-title');
  if (topTitle) topTitle.textContent = titles[viewName] || 'لوحة التحكم';

  // تحميل بيانات المشهد
  if (viewName === 'overview') renderOverviewStats();
  if (viewName === 'orders') renderOrdersTable();
  if (viewName === 'products') renderProductsTable();
  if (viewName === 'categories') renderCategoriesView();
  if (viewName === 'offers') {
    renderAdminOffers();
    renderAdminCoupons();
  }
  if (viewName === 'settings') loadSettingsForm();
}

// ==========================================
// 4. تحديث الإحصائيات (KPIs)
// ==========================================
function updateDashboardStats() {
  const totalOrders = adminState.orders.length;
  const pendingOrders = adminState.orders.filter(o => o.status === 'Pending').length;
  const totalProducts = adminState.products.length;
  const verifiedProducts = adminState.products.filter(p => !p.isSample).length;
  const activeOffers = adminState.offers.filter(o => o.isActive !== false).length;
  const totalRevenue = adminState.orders
    .filter(o => o.status === 'Delivered' || o.status === 'Confirmed')
    .reduce((sum, o) => sum + (o.total || 0), 0);

  // تحديث الأرقام في الواجهة
  const elTotalOrders = document.getElementById('stat-total-orders');
  const elPendingOrders = document.getElementById('stat-pending-orders');
  const elRevenue = document.getElementById('stat-revenue');
  const elTotalProducts = document.getElementById('stat-total-products');
  const elSidebarBadge = document.getElementById('sidebar-pending-badge');
  const elOffersBadge = document.getElementById('sidebar-offers-badge');

  if (elTotalOrders) elTotalOrders.textContent = totalOrders;
  if (elPendingOrders) elPendingOrders.textContent = pendingOrders;
  if (elRevenue) elRevenue.textContent = `${totalRevenue} ج.م`;
  if (elTotalProducts) elTotalProducts.textContent = `${totalProducts} (${verifiedProducts} معتمد)`;
  if (elSidebarBadge) {
    elSidebarBadge.textContent = pendingOrders;
    elSidebarBadge.style.display = pendingOrders > 0 ? 'inline-block' : 'none';
  }
  if (elOffersBadge) {
    elOffersBadge.textContent = activeOffers;
    elOffersBadge.style.display = activeOffers > 0 ? 'inline-block' : 'none';
  }
}

function renderOverviewStats() {
  updateDashboardStats();
  const recentOrdersContainer = document.getElementById('overview-recent-orders');
  if (!recentOrdersContainer) return;

  const recent = adminState.orders.slice(0, 5);
  if (recent.length === 0) {
    recentOrdersContainer.innerHTML = '<tr><td colspan="6" style="text-align:center; padding: 25px; color: var(--admin-text-muted);">لا توجد طلبات مسجلة حتى الآن.</td></tr>';
    return;
  }

  recentOrdersContainer.innerHTML = recent.map(order => `
    <tr>
      <td><strong>${order.orderRef}</strong></td>
      <td>${order.customerName}<br><small style="color:var(--admin-text-muted);">${order.customerPhone}</small></td>
      <td>${order.orderType === 'delivery' ? '🛵 توصيل' : '🛍️ استلام'}</td>
      <td><strong style="color:var(--admin-primary);">${order.total} ج.م</strong></td>
      <td>${getStatusBadge(order.status)}</td>
      <td><small>${new Date(order.createdAt).toLocaleTimeString('ar-EG')}</small></td>
    </tr>
  `).join('');
}

// ==========================================
// 5. إدارة ومتابعة الطلبات كبطاقات ذكية تفاعلية (Orders Cards Grid)
// لتجنب السكرول الأفقي نهائياً وتوفير تجربة مريحة وسريعة للموبايل والكمبيوتر
// ==========================================
function renderOrdersTable() {
  const container = document.getElementById('orders-cards-container') || document.getElementById('orders-table-body');
  if (!container) return;

  let filtered = [...adminState.orders];

  // تصفية حسب الحالة
  if (adminState.ordersFilter !== 'all') {
    filtered = filtered.filter(o => o.status === adminState.ordersFilter);
  }

  // بحث
  if (adminState.ordersSearch) {
    const q = adminState.ordersSearch.toLowerCase();
    filtered = filtered.filter(o => 
      (o.orderRef && o.orderRef.toLowerCase().includes(q)) ||
      (o.customerName && o.customerName.toLowerCase().includes(q)) ||
      (o.customerPhone && o.customerPhone.includes(q)) ||
      (o.area && o.area.toLowerCase().includes(q)) ||
      (o.address && o.address.toLowerCase().includes(q))
    );
  }

  if (filtered.length === 0) {
    const isSearchingOrFiltering = adminState.ordersFilter !== 'all' || adminState.ordersSearch;
    container.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 50px 20px; color: var(--admin-text-muted); background: var(--admin-card-bg); border-radius: var(--radius-md); border: 1px dashed var(--admin-border);">
        <i class="fas fa-clipboard-check" style="font-size: 44px; margin-bottom: 12px; opacity: 0.35;"></i>
        <h4 style="font-size: 15px; font-weight: 800; color: var(--admin-text-main); margin-bottom: 6px;">
          ${isSearchingOrFiltering ? 'لا توجد طلبات تطابق هذا التصنيف' : 'لا توجد طلبات واردة حالياً'}
        </h4>
        <p style="font-size: 12.5px; margin-bottom: 14px;">
          ${isSearchingOrFiltering ? 'جرّب اختيار تصنيف آخر من الأعلى أو مسح كلمة البحث.' : 'سجل الطلبات فارغ، ستظهر الطلبات الجديدة هنا مباشرة عند قيام العملاء بالطلب من الموقع.'}
        </p>
        ${!isSearchingOrFiltering ? `
          <button class="btn-admin-action ghost" onclick="addSampleOrder()" style="font-size: 12px; margin: 0 auto; display: inline-flex; align-items: center; gap: 6px;">
            <i class="fas fa-plus-circle"></i> إضافة طلب تجريبي للاختبار
          </button>
        ` : ''}
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(order => {
    // تنظيف رقم هاتف العميل للتواصل عبر واتساب
    let cleanPhone = (order.customerPhone || '').replace(/[^0-9]/g, '');
    if (cleanPhone.startsWith('01')) cleanPhone = '20' + cleanPhone.substring(1);

    const waCustomerUrl = `https://wa.me/${cleanPhone}?text=${encodeURIComponent(`مرحباً أستاذ ${order.customerName}، معكم إدارة مطعم بيتزا أولاد الشيخ بخصوص طلبكم رقم ${order.orderRef}...`)}`;

    const formattedTime = new Date(order.createdAt).toLocaleString('ar-EG', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });

    const totalQty = (order.items || []).reduce((sum, item) => sum + (item.quantity || 1), 0);

    return `
      <div class="order-card" data-status="${order.status}">
        <!-- 1. ترويسة الكرت -->
        <div class="order-card-header">
          <div class="order-card-ref-group">
            <span class="order-ref-badge">${order.orderRef}</span>
            <span class="order-type-badge ${order.orderType === 'delivery' ? 'delivery' : 'takeaway'}">
              <i class="fas ${order.orderType === 'delivery' ? 'fa-motorcycle' : 'fa-shopping-bag'}"></i>
              ${order.orderType === 'delivery' ? 'توصيل للمنزل' : 'استلام من المطعم'}
            </span>
          </div>
          <div class="order-card-time">
            <i class="far fa-clock"></i>
            <span>${formattedTime}</span>
          </div>
        </div>

        <!-- 2. بيانات العميل والتواصل السريع -->
        <div class="order-card-customer">
          <div class="customer-info-main">
            <div class="customer-avatar">
              <i class="fas fa-user"></i>
            </div>
            <div>
              <div class="customer-name">${order.customerName}</div>
              <div class="customer-phone">${order.customerPhone}</div>
            </div>
          </div>
          <div class="customer-quick-actions">
            <a href="tel:${order.customerPhone}" class="btn-customer-action tel" title="اتصال هاتفي مباشر">
              <i class="fas fa-phone-alt"></i>
              <span>اتصال</span>
            </a>
            <a href="${waCustomerUrl}" target="_blank" class="btn-customer-action wa" title="محادثة واتساب">
              <i class="fab fa-whatsapp"></i>
              <span>واتساب</span>
            </a>
          </div>
        </div>

        <!-- 3. تفاصيل العنوان وموقع GPS -->
        ${order.orderType === 'delivery' || order.area || order.address ? `
        <div class="order-card-address">
          <i class="fas fa-map-marker-alt" style="color: var(--admin-primary); margin-top: 3px; flex-shrink: 0;"></i>
          <div style="flex: 1;">
            <div>${order.area ? `<strong>${order.area}</strong>` : ''}${order.area && order.address ? ' - ' : ''}${order.address || ''}</div>
            ${order.locationUrl ? `
              <div style="margin-top: 5px;">
                <a href="${order.locationUrl}" target="_blank" class="gps-link">
                  <i class="fas fa-location-arrow"></i> فتح موقع العميل على الخريطة (GPS)
                </a>
              </div>
            ` : ''}
          </div>
        </div>
        ` : ''}

        <!-- 4. تفاصيل الأصناف والطلبات -->
        <div class="order-card-items">
          <div class="items-header">
            <span><i class="fas fa-utensils"></i> الأصناف المطلوبة (${totalQty}):</span>
          </div>
          <div class="items-list">
            ${(order.items || []).map(item => `
              <div>
                <div class="item-row">
                  <div class="item-qty-name">
                    <span class="item-qty">x${item.quantity || 1}</span>
                    <span class="item-name">${item.name}</span>
                    ${item.size ? `<span class="item-size">(${item.size})</span>` : ''}
                  </div>
                  <div class="item-price">${(item.totalPrice || item.price * (item.quantity || 1))} ج.م</div>
                </div>
                ${item.extras && item.extras.length > 0 ? `
                  <div class="item-extras">+ إضافات: ${item.extras.join('، ')}</div>
                ` : ''}
              </div>
            `).join('')}
          </div>
          ${order.instructions ? `
            <div class="order-instructions-box">
              <i class="fas fa-comment-dots" style="flex-shrink: 0; margin-top: 2px;"></i>
              <span><strong>ملاحظات العميل:</strong> ${order.instructions}</span>
            </div>
          ` : ''}
        </div>

        <!-- 5. شريط الإجمالي وطريقة الدفع -->
        <div class="order-card-financial">
          <div class="total-highlight">
            <span>المبلغ الإجمالي:</span>
            <span class="total-amount">${order.total} ج.م</span>
          </div>
          <div class="payment-method-badge">
            <i class="fas fa-wallet"></i> ${order.paymentMethod || 'الدفع عند الاستلام (كاش)'}
          </div>
        </div>

        <!-- 6. شريط التحكم بحالة الطلب والحذف -->
        <div class="order-card-footer">
          <div class="status-selector-wrapper">
            <span class="status-label">حالة الطلب:</span>
            <select class="form-control status-select" onchange="updateOrderStatus('${order.orderRef}', this.value)">
              <option value="Pending" ${order.status === 'Pending' ? 'selected' : ''}>⏳ قيد المراجعة</option>
              <option value="Confirmed" ${order.status === 'Confirmed' ? 'selected' : ''}>✔️ تم التأكيد</option>
              <option value="Preparing" ${order.status === 'Preparing' ? 'selected' : ''}>🔥 قيد التجهيز</option>
              <option value="OutForDelivery" ${order.status === 'OutForDelivery' ? 'selected' : ''}>🛵 في الطريق</option>
              <option value="Delivered" ${order.status === 'Delivered' ? 'selected' : ''}>✅ تم التسليم</option>
              <option value="Cancelled" ${order.status === 'Cancelled' ? 'selected' : ''}>❌ ملغي</option>
            </select>
          </div>
          <button class="btn-delete-order" onclick="deleteOrder('${order.orderRef}')" title="حذف الطلب">
            <i class="fas fa-trash-alt"></i>
          </button>
        </div>
      </div>
    `;
  }).join('');
}

function getStatusBadge(status) {
  switch (status) {
    case 'Pending': return '<span class="badge-status pending">قيد المراجعة</span>';
    case 'Confirmed': return '<span class="badge-status confirmed">تم التأكيد</span>';
    case 'Preparing': return '<span class="badge-status preparing">قيد التجهيز</span>';
    case 'OutForDelivery': return '<span class="badge-status out">في الطريق</span>';
    case 'Delivered': return '<span class="badge-status delivered">تم التسليم</span>';
    case 'Cancelled': return '<span class="badge-status cancelled">ملغي</span>';
    default: return `<span class="badge-status">${status}</span>`;
  }
}

function updateOrderStatus(orderRef, newStatus) {
  const order = adminState.orders.find(o => o.orderRef === orderRef);
  if (order) {
    order.status = newStatus;
    saveOrders();
    renderOrdersTable();
    showToast(`تم تحديث حالة الطلب ${orderRef} إلى: ${getStatusText(newStatus)}`);
  }
}

function getStatusText(status) {
  const map = {
    Pending: 'قيد المراجعة',
    Confirmed: 'تم التأكيد',
    Preparing: 'قيد التجهيز',
    OutForDelivery: 'في الطريق',
    Delivered: 'تم التسليم',
    Cancelled: 'ملغي'
  };
  return map[status] || status;
}

function deleteOrder(orderRef) {
  if (confirm(`هل أنت متأكد من حذف الطلب رقم ${orderRef} نهائياً؟`)) {
    adminState.orders = adminState.orders.filter(o => o.orderRef !== orderRef);
    saveOrders();
    renderOrdersTable();
    showToast('تم حذف الطلب بنجاح ولن يظهر مجدداً.');
  }
}

function clearAllOrders() {
  if (!adminState.orders || adminState.orders.length === 0) {
    showToast('سجل الطلبات فارغ بالفعل.');
    return;
  }
  if (confirm('هل أنت متأكد من مسح وتفريغ جميع الطلبات نهائياً من السجل؟')) {
    adminState.orders = [];
    saveOrders();
    renderOrdersTable();
    showToast('تم مسح جميع الطلبات بنجاح ولن تعود عند التحديث.');
  }
}

function addSampleOrder() {
  const sample = {
    orderRef: '#ORD-' + Math.floor(1000 + Math.random() * 9000),
    customerName: 'عميل تجريبي',
    customerPhone: '01112962692',
    orderType: 'delivery',
    address: 'شارع الوحدة الرئيسي، إمبابة، الجيزة',
    area: 'إمبابة',
    createdAt: new Date().toISOString(),
    status: 'Pending',
    items: [
      { name: 'بيتزا سوبر سوبريم', size: 'وسط (28 سم)', quantity: 1, price: 130, extras: 'إكسترا جبنة' }
    ],
    total: 150,
    paymentMethod: 'الدفع عند الاستلام (كاش)',
    notes: 'طلب تجريبي لتجربة لوحة التحكم'
  };
  adminState.orders.unshift(sample);
  saveOrders();
  renderOrdersTable();
  showToast('تمت إضافة طلب تجريبي جديد.');
}

function filterOrdersByStatus(status) {
  adminState.ordersFilter = status;
  document.querySelectorAll('.order-filter-pill').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.status === status);
  });
  renderOrdersTable();
}

function searchOrders(query) {
  adminState.ordersSearch = query.trim();
  renderOrdersTable();
}

// ==========================================
// 6. إدارة قائمة الطعام والأسعار (Products Management)
// ==========================================
function renderProductsTable() {
  const container = document.getElementById('products-table-body');
  if (!container) return;

  let filtered = [...adminState.products];

  // تصفية حسب التصنيف
  if (adminState.productsFilter !== 'all') {
    filtered = filtered.filter(p => p.categoryId === adminState.productsFilter);
  }

  // تصفية بالبحث
  if (adminState.productsSearch) {
    const q = adminState.productsSearch.toLowerCase();
    filtered = filtered.filter(p => 
      (p.nameAr && p.nameAr.toLowerCase().includes(q)) ||
      (p.nameEn && p.nameEn.toLowerCase().includes(q))
    );
  }

  container.innerHTML = filtered.map(prod => {
    const cat = adminState.categories.find(c => c.id === prod.categoryId);
    const catName = cat ? cat.nameAr : 'عام';

    return `
      <tr>
        <td style="width: 60px;">
          <img src="${prod.imageUrl || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=100'}" alt="${prod.nameAr}" style="width: 50px; height: 50px; border-radius: 8px; object-fit: cover;">
        </td>
        <td>
          <div style="font-weight: 800; font-size: 14px;">${prod.nameAr}</div>
          <div style="font-size: 11.5px; color: var(--admin-text-muted);">${prod.nameEn || ''}</div>
          <span style="font-size: 11px; background: var(--admin-bg); padding: 2px 6px; border-radius: 4px; color: var(--admin-text-muted);">${catName}</span>
        </td>
        <td style="width: 140px;">
          <div style="display: flex; align-items: center; gap: 4px;">
            <input type="number" class="form-control" value="${prod.basePrice}" style="width: 80px; padding: 6px;" onchange="quickUpdateProductPrice('${prod.id}', this.value)">
            <span style="font-size: 13px; font-weight: 700;">ج.م</span>
          </div>
        </td>
        <td>
          <button class="btn-admin-action ${prod.isSample ? 'warning' : 'success'}" onclick="toggleProductSample('${prod.id}')" title="اضغط للتبديل بين عينة ومعتمد">
            ${prod.isSample ? '<i class="fas fa-exclamation-circle"></i> عينة تجريبية' : '<i class="fas fa-check-circle"></i> معتمد رسمي'}
          </button>
        </td>
        <td>
          <button class="btn-admin-action ${prod.isAvailable ? 'success' : 'danger'}" onclick="toggleProductAvailability('${prod.id}')">
            ${prod.isAvailable ? '<i class="fas fa-check"></i> متاح للطلب' : '<i class="fas fa-ban"></i> غير متوفر'}
          </button>
        </td>
        <td>
          <div style="display: flex; gap: 6px;">
            <button class="btn-admin-action ghost" onclick="openEditProductModal('${prod.id}')" title="تعديل التفاصيل">
              <i class="fas fa-edit"></i>
            </button>
            <button class="btn-admin-action danger" onclick="deleteProduct('${prod.id}')" title="حذف الصنف">
              <i class="fas fa-trash-alt"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

function quickUpdateProductPrice(prodId, newPrice) {
  const p = adminState.products.find(item => item.id === prodId);
  if (p) {
    p.basePrice = parseFloat(newPrice) || p.basePrice;
    saveProducts();
    showToast(`تم تحديث سعر ${p.nameAr} إلى ${p.basePrice} ج.م`);
  }
}

function toggleProductSample(prodId) {
  const p = adminState.products.find(item => item.id === prodId);
  if (p) {
    p.isSample = !p.isSample;
    saveProducts();
    renderProductsTable();
    showToast(`تم تعيين ${p.nameAr} كـ: ${p.isSample ? 'عينة تجريبية' : 'معتمد رسمياً'}`);
  }
}

function toggleProductAvailability(prodId) {
  const p = adminState.products.find(item => item.id === prodId);
  if (p) {
    p.isAvailable = !p.isAvailable;
    saveProducts();
    renderProductsTable();
    showToast(`تم تغيير حالة ${p.nameAr} إلى: ${p.isAvailable ? 'متاح للطلب' : 'غير متوفر'}`);
  }
}

function deleteProduct(prodId) {
  const p = adminState.products.find(item => item.id === prodId);
  if (!p) return;
  if (confirm(`هل أنت متأكد من حذف المنتج "${p.nameAr}" من قائمة الطعام؟`)) {
    adminState.products = adminState.products.filter(item => item.id !== prodId);
    saveProducts();
    renderProductsTable();
    showToast(`تم حذف ${p.nameAr} بنجاح.`);
  }
}

// نافذة تعديل / إضافة منتج
function openAddProductModal() {
  populateCategoryDropdowns();
  adminState.editingProduct = null;
  document.getElementById('modal-product-title').textContent = 'إضافة صنف جديد للقائمة';
  document.getElementById('form-product-name-ar').value = '';
  document.getElementById('form-product-name-en').value = '';
  document.getElementById('form-product-cat').value = adminState.categories[0]?.id || 'cat-1';
  document.getElementById('form-product-price').value = '100';
  document.getElementById('form-product-desc-ar').value = '';
  document.getElementById('form-product-img').value = '';
  document.getElementById('form-product-sample').checked = false;
  document.getElementById('form-product-avail').checked = true;

  document.getElementById('product-modal').style.display = 'flex';
}

function openEditProductModal(prodId) {
  populateCategoryDropdowns();
  const p = adminState.products.find(item => item.id === prodId);
  if (!p) return;

  adminState.editingProduct = p;
  document.getElementById('modal-product-title').textContent = `تعديل صنف: ${p.nameAr}`;
  document.getElementById('form-product-name-ar').value = p.nameAr || '';
  document.getElementById('form-product-name-en').value = p.nameEn || '';
  document.getElementById('form-product-cat').value = p.categoryId || (adminState.categories[0]?.id || 'cat-1');
  document.getElementById('form-product-price').value = p.basePrice || 0;
  document.getElementById('form-product-desc-ar').value = p.descriptionAr || '';
  document.getElementById('form-product-img').value = p.imageUrl || '';
  document.getElementById('form-product-sample').checked = p.isSample === true;
  document.getElementById('form-product-avail').checked = p.isAvailable !== false;

  document.getElementById('product-modal').style.display = 'flex';
}

function closeProductEditModal() {
  document.getElementById('product-modal').style.display = 'none';
  adminState.editingProduct = null;
}

function handleSaveProduct(e) {
  e.preventDefault();
  const nameAr = document.getElementById('form-product-name-ar').value.trim();
  const nameEn = document.getElementById('form-product-name-en').value.trim();
  const categoryId = document.getElementById('form-product-cat').value;
  const basePrice = parseFloat(document.getElementById('form-product-price').value) || 0;
  const descAr = document.getElementById('form-product-desc-ar').value.trim();
  const imgUrl = document.getElementById('form-product-img').value.trim() || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800';
  const isSample = document.getElementById('form-product-sample').checked;
  const isAvailable = document.getElementById('form-product-avail').checked;

  if (!nameAr) {
    alert('يرجى كتابة اسم الصنف بالعربية.');
    return;
  }

  if (adminState.editingProduct) {
    // تعديل
    adminState.editingProduct.nameAr = nameAr;
    adminState.editingProduct.nameEn = nameEn;
    adminState.editingProduct.categoryId = categoryId;
    adminState.editingProduct.basePrice = basePrice;
    adminState.editingProduct.descriptionAr = descAr;
    adminState.editingProduct.imageUrl = imgUrl;
    adminState.editingProduct.isSample = isSample;
    adminState.editingProduct.isAvailable = isAvailable;
    showToast(`تم تحديث الصنف ${nameAr} بنجاح.`);
  } else {
    // إضافة جديد
    const newProduct = {
      id: 'p-' + Date.now(),
      categoryId: categoryId,
      nameAr: nameAr,
      nameEn: nameEn,
      descriptionAr: descAr,
      descriptionEn: '',
      imageUrl: imgUrl,
      basePrice: basePrice,
      isAvailable: isAvailable,
      isSample: isSample,
      isFeatured: false,
      isBestSeller: false,
      sizes: [
        { id: 's-m', nameAr: 'وسط', nameEn: 'Medium', price: basePrice, isDefault: true },
        { id: 's-l', nameAr: 'كبير', nameEn: 'Large', price: Math.round(basePrice * 1.35), isDefault: false }
      ],
      extras: [
        { id: 'e-m', nameAr: 'موتزاريلا زيادة', nameEn: 'Extra Mozzarella', price: 25.0 }
      ]
    };
    adminState.products.unshift(newProduct);
    showToast(`تمت إضافة ${nameAr} إلى قائمة الطعام بنجاح.`);
  }

  saveProducts();
  renderProductsTable();
  closeProductEditModal();
}

// ==========================================
// 6.0 إدارة وتخصيص التصنيفات (Categories Management)
// ==========================================
const QUICK_CATEGORY_ICONS = [
  { icon: 'fa-pizza-slice', label: 'بيتزا' },
  { icon: 'fa-bread-slice', label: 'كريب' },
  { icon: 'fa-burger', label: 'برجر' },
  { icon: 'fa-hotdog', label: 'سندوتشات' },
  { icon: 'fa-drumstick-bite', label: 'حواوشي/دجاج' },
  { icon: 'fa-pie-chart', label: 'فطير' },
  { icon: 'fa-plate-wheat', label: 'باستا/مكرونة' },
  { icon: 'fa-bowl-food', label: 'أطباق ومقبلات' },
  { icon: 'fa-bottle-water', label: 'مشروبات' },
  { icon: 'fa-fire', label: 'سبايسي' },
  { icon: 'fa-ice-cream', label: 'حلويات' },
  { icon: 'fa-tag', label: 'تصنيف عام' }
];

function populateCategoryDropdowns() {
  const filterSelect = document.getElementById('products-category-filter');
  if (filterSelect) {
    const currentVal = filterSelect.value || 'all';
    let optionsHtml = '<option value="all">كل التصنيفات</option>';
    adminState.categories.forEach(cat => {
      optionsHtml += `<option value="${cat.id}" ${currentVal === cat.id ? 'selected' : ''}>${cat.nameAr}</option>`;
    });
    filterSelect.innerHTML = optionsHtml;
  }

  const formProdCat = document.getElementById('form-product-cat');
  if (formProdCat) {
    const currentVal = formProdCat.value;
    let optionsHtml = '';
    adminState.categories.forEach(cat => {
      optionsHtml += `<option value="${cat.id}" ${currentVal === cat.id ? 'selected' : ''}>${cat.nameAr}</option>`;
    });
    formProdCat.innerHTML = optionsHtml;
  }
}

function renderCategoriesView() {
  const container = document.getElementById('categories-cards-container');
  if (!container) return;

  if (adminState.categories.length === 0) {
    container.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 50px 20px; color: var(--admin-text-muted); background: var(--admin-card-bg); border-radius: var(--radius-md); border: 1px dashed var(--admin-border);">
        <i class="fas fa-tags" style="font-size: 44px; margin-bottom: 12px; opacity: 0.35;"></i>
        <h4 style="font-size: 15px; font-weight: 800; color: var(--admin-text-main); margin-bottom: 6px;">لا توجد أي تصنيفات حالياً</h4>
        <p style="font-size: 12.5px; margin-bottom: 14px;">أضف تصنيفاً جديداً لتنظيم أقسام المنيو وتسهيل تصفح العملاء.</p>
        <button class="btn-admin-action primary" onclick="openAddCategoryModal()">
          <i class="fas fa-plus"></i> إضافة تصنيف جديد
        </button>
      </div>
    `;
    return;
  }

  container.innerHTML = adminState.categories.map(cat => {
    const productCount = adminState.products.filter(p => p.categoryId === cat.id).length;

    return `
      <div class="category-card" data-id="${cat.id}">
        <div class="category-card-header">
          <div class="category-card-icon">
            <i class="fas ${cat.icon || 'fa-tag'}"></i>
          </div>
          <div class="category-card-info">
            <div class="category-card-name-ar">${cat.nameAr}</div>
            <div class="category-card-name-en">${cat.nameEn || '—'}</div>
          </div>
        </div>

        <div class="category-card-meta">
          <span style="color: var(--admin-text-muted);"><i class="fas fa-utensils"></i> الأصناف المسجلة:</span>
          <span style="font-weight: 800; color: var(--admin-primary);">${productCount} صنف</span>
        </div>

        <div class="category-card-actions">
          <button class="btn-admin-action ghost" onclick="openEditCategoryModal('${cat.id}')" title="تعديل التصنيف">
            <i class="fas fa-edit"></i> <span>تعديل</span>
          </button>
          <button class="btn-admin-action danger" onclick="deleteCategory('${cat.id}')" title="حذف التصنيف">
            <i class="fas fa-trash-alt"></i> <span>حذف</span>
          </button>
        </div>
      </div>
    `;
  }).join('');
}

function renderQuickIconsPicker(selectedIcon) {
  const container = document.getElementById('quick-icons-picker');
  if (!container) return;

  container.innerHTML = QUICK_CATEGORY_ICONS.map(item => `
    <button type="button" class="quick-icon-btn ${item.icon === selectedIcon ? 'selected' : ''}" 
      title="${item.label}" onclick="setCategoryIcon('${item.icon}')">
      <i class="fas ${item.icon}"></i>
    </button>
  `).join('');
}

function setCategoryIcon(iconClass) {
  const input = document.getElementById('form-category-icon');
  if (input) {
    input.value = iconClass;
    updateCategoryIconPreview(iconClass);
  }
  document.querySelectorAll('.quick-icon-btn').forEach(btn => {
    const iconEl = btn.querySelector('i');
    btn.classList.toggle('selected', iconEl && iconEl.classList.contains(iconClass));
  });
}

function updateCategoryIconPreview(iconClass) {
  const preview = document.getElementById('category-icon-preview');
  if (preview) {
    preview.innerHTML = `<i class="fas ${iconClass || 'fa-tag'}"></i>`;
  }
}

function openAddCategoryModal() {
  document.getElementById('modal-category-title').innerHTML = '<i class="fas fa-plus-circle" style="color: var(--admin-primary);"></i> إضافة تصنيف جديد';
  document.getElementById('form-category-id').value = '';
  document.getElementById('form-category-name-ar').value = '';
  document.getElementById('form-category-name-en').value = '';
  document.getElementById('form-category-icon').value = 'fa-pizza-slice';
  updateCategoryIconPreview('fa-pizza-slice');
  renderQuickIconsPicker('fa-pizza-slice');
  document.getElementById('modal-category').style.display = 'flex';
}

function openEditCategoryModal(catId) {
  const cat = adminState.categories.find(c => c.id === catId);
  if (!cat) return;

  document.getElementById('modal-category-title').innerHTML = `<i class="fas fa-edit" style="color: var(--admin-primary);"></i> تعديل تصنيف: ${cat.nameAr}`;
  document.getElementById('form-category-id').value = cat.id;
  document.getElementById('form-category-name-ar').value = cat.nameAr;
  document.getElementById('form-category-name-en').value = cat.nameEn || '';
  const currentIcon = cat.icon || 'fa-tag';
  document.getElementById('form-category-icon').value = currentIcon;
  updateCategoryIconPreview(currentIcon);
  renderQuickIconsPicker(currentIcon);
  document.getElementById('modal-category').style.display = 'flex';
}

function closeCategoryModal() {
  document.getElementById('modal-category').style.display = 'none';
}

function handleSaveCategory(e) {
  e.preventDefault();
  const id = document.getElementById('form-category-id').value;
  const nameAr = document.getElementById('form-category-name-ar').value.trim();
  const nameEn = document.getElementById('form-category-name-en').value.trim() || nameAr;
  let icon = document.getElementById('form-category-icon').value.trim() || 'fa-tag';
  if (!icon.startsWith('fa-')) icon = 'fa-' + icon;

  if (!nameAr) {
    alert('يرجى إدخال اسم التصنيف باللغة العربية.');
    return;
  }

  if (id) {
    // تعديل تصنيف حالي
    const index = adminState.categories.findIndex(c => c.id === id);
    if (index !== -1) {
      adminState.categories[index] = {
        ...adminState.categories[index],
        nameAr,
        nameEn,
        icon
      };
      showToast(`تم تعديل تصنيف "${nameAr}" بنجاح.`);
    }
  } else {
    // إضافة تصنيف جديد
    const newId = 'cat-' + Date.now();
    adminState.categories.push({
      id: newId,
      nameAr,
      nameEn,
      icon
    });
    showToast(`تمت إضافة تصنيف "${nameAr}" بنجاح.`);
  }

  saveCategories();
  closeCategoryModal();
}

function deleteCategory(catId) {
  const cat = adminState.categories.find(c => c.id === catId);
  if (!cat) return;

  const attachedProducts = adminState.products.filter(p => p.categoryId === catId);
  let confirmMsg = `هل أنت متأكد من حذف تصنيف "${cat.nameAr}"؟`;
  if (attachedProducts.length > 0) {
    confirmMsg += `\n⚠️ تنبيه: يوجد ${attachedProducts.length} صنف مسجل تحت هذا التصنيف! سيتم تحويلها بدون تصنيف.`;
  }

  if (confirm(confirmMsg)) {
    adminState.categories = adminState.categories.filter(c => c.id !== catId);
    if (attachedProducts.length > 0) {
      adminState.products.forEach(p => {
        if (p.categoryId === catId) p.categoryId = '';
      });
      saveProducts();
    }
    saveCategories();
    showToast(`تم حذف تصنيف "${cat.nameAr}" بنجاح.`);
  }
}

// ==========================================
// 6.1 إدارة العروض والخصومات (Offers Management)
// ==========================================
function renderAdminOffers() {
  const container = document.getElementById('admin-offers-table-body');
  if (!container) return;

  if (adminState.offers.length === 0) {
    container.innerHTML = `
      <tr>
        <td colspan="7" style="text-align: center; padding: 35px; color: var(--admin-text-muted);">
          <i class="fas fa-percent" style="font-size: 32px; margin-bottom: 8px; opacity: 0.5;"></i>
          <p>لا توجد عروض مسجلة حالياً. اضغط على "إضافة عرض جديد" للبدء.</p>
        </td>
      </tr>
    `;
    return;
  }

  container.innerHTML = adminState.offers.map(offer => {
    const savings = offer.originalPrice ? Math.round(offer.originalPrice - offer.offerPrice) : 0;
    const discountPercent = offer.originalPrice 
      ? Math.round(((offer.originalPrice - offer.offerPrice) / offer.originalPrice) * 100) 
      : 0;

    return `
      <tr>
        <td style="width: 60px;">
          <img src="${offer.imageUrl || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=100'}" alt="${offer.titleAr}" style="width: 50px; height: 50px; border-radius: 8px; object-fit: cover;">
        </td>
        <td>
          <div style="font-weight: 800; font-size: 14px;">${offer.titleAr}</div>
          <div style="font-size: 11.5px; color: var(--admin-text-muted); max-width: 250px;">${offer.descriptionAr}</div>
          ${offer.expiryDate ? `<div style="font-size: 11px; color: #b45309; margin-top: 2px;">ينتهي في: ${offer.expiryDate}</div>` : ''}
        </td>
        <td>
          <span style="background: linear-gradient(135deg, var(--admin-secondary), #d84315); color: white; padding: 3px 8px; border-radius: 12px; font-size: 11px; font-weight: 800;">
            ${offer.badge || 'عرض خاص'}
          </span>
        </td>
        <td>
          <div style="font-weight: 800; color: var(--admin-primary); font-size: 15px;">${offer.offerPrice} ج.م</div>
          ${offer.originalPrice ? `<div style="font-size: 12px; color: var(--admin-text-muted); text-decoration: line-through;">${offer.originalPrice} ج.م</div>` : ''}
          ${discountPercent > 0 ? `<div style="font-size: 11px; color: #16a34a; font-weight: 700;">خصم ${discountPercent}% (توفير ${savings} ج.م)</div>` : ''}
        </td>
        <td>
          <button class="btn-admin-action ${offer.isSample ? 'warning' : 'success'}" onclick="toggleOfferSample('${offer.id}')" title="اضغط للتبديل">
            ${offer.isSample ? '<i class="fas fa-exclamation-circle"></i> عينة تجريبية' : '<i class="fas fa-check-circle"></i> معتمد رسمي'}
          </button>
        </td>
        <td>
          <button class="btn-admin-action ${offer.isActive !== false ? 'success' : 'danger'}" onclick="toggleOfferActive('${offer.id}')">
            ${offer.isActive !== false ? '<i class="fas fa-eye"></i> يظهر بالموقع' : '<i class="fas fa-eye-slash"></i> معطل ومخفي'}
          </button>
        </td>
        <td>
          <div style="display: flex; gap: 6px;">
            <button class="btn-admin-action ghost" onclick="openEditOfferModal('${offer.id}')" title="تعديل تفاصيل العرض">
              <i class="fas fa-edit"></i>
            </button>
            <button class="btn-admin-action danger" onclick="deleteOffer('${offer.id}')" title="حذف العرض">
              <i class="fas fa-trash-alt"></i>
            </button>
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

function toggleOfferSample(offerId) {
  const o = adminState.offers.find(item => item.id === offerId);
  if (o) {
    o.isSample = !o.isSample;
    saveOffers();
    renderAdminOffers();
    showToast(`تم تعيين العرض (${o.titleAr}) كـ: ${o.isSample ? 'عينة تجريبية' : 'معتمد رسمياً'}`);
  }
}

function toggleOfferActive(offerId) {
  const o = adminState.offers.find(item => item.id === offerId);
  if (o) {
    o.isActive = o.isActive === false ? true : false;
    saveOffers();
    renderAdminOffers();
    showToast(`تم تغيير ظهور العرض بالموقع إلى: ${o.isActive ? 'مفعل ويظهر للعملاء' : 'معطل ومخفي'}`);
  }
}

function deleteOffer(offerId) {
  const o = adminState.offers.find(item => item.id === offerId);
  if (!o) return;
  if (confirm(`هل أنت متأكد من حذف العرض "${o.titleAr}" نهائياً؟`)) {
    adminState.offers = adminState.offers.filter(item => item.id !== offerId);
    saveOffers();
    renderAdminOffers();
    showToast(`تم حذف العرض بنجاح.`);
  }
}

function openAddOfferModal() {
  adminState.editingOffer = null;
  document.getElementById('modal-offer-title').textContent = 'إضافة عرض ترويجي جديد';
  document.getElementById('form-offer-title-ar').value = '';
  document.getElementById('form-offer-desc-ar').value = '';
  document.getElementById('form-offer-orig-price').value = '';
  document.getElementById('form-offer-price').value = '';
  document.getElementById('form-offer-badge').value = 'وفر 20%';
  document.getElementById('form-offer-expiry').value = '2026-12-31';
  document.getElementById('form-offer-img').value = '';
  document.getElementById('form-offer-sample').checked = false;
  document.getElementById('form-offer-active').checked = true;

  document.getElementById('offer-modal').style.display = 'flex';
}

function openEditOfferModal(offerId) {
  const o = adminState.offers.find(item => item.id === offerId);
  if (!o) return;

  adminState.editingOffer = o;
  document.getElementById('modal-offer-title').textContent = `تعديل العرض: ${o.titleAr}`;
  document.getElementById('form-offer-title-ar').value = o.titleAr || '';
  document.getElementById('form-offer-desc-ar').value = o.descriptionAr || '';
  document.getElementById('form-offer-orig-price').value = o.originalPrice || '';
  document.getElementById('form-offer-price').value = o.offerPrice || '';
  document.getElementById('form-offer-badge').value = o.badge || '';
  document.getElementById('form-offer-expiry').value = o.expiryDate || '';
  document.getElementById('form-offer-img').value = o.imageUrl || '';
  document.getElementById('form-offer-sample').checked = o.isSample === true;
  document.getElementById('form-offer-active').checked = o.isActive !== false;

  document.getElementById('offer-modal').style.display = 'flex';
}

function closeOfferModal() {
  document.getElementById('offer-modal').style.display = 'none';
  adminState.editingOffer = null;
}

function handleSaveOffer(e) {
  e.preventDefault();
  const titleAr = document.getElementById('form-offer-title-ar').value.trim();
  const descAr = document.getElementById('form-offer-desc-ar').value.trim();
  const origPrice = parseFloat(document.getElementById('form-offer-orig-price').value) || null;
  const offerPrice = parseFloat(document.getElementById('form-offer-price').value) || 0;
  const badge = document.getElementById('form-offer-badge').value.trim() || 'عرض خاص';
  const expiry = document.getElementById('form-offer-expiry').value;
  const imgUrl = document.getElementById('form-offer-img').value.trim() || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800';
  const isSample = document.getElementById('form-offer-sample').checked;
  const isActive = document.getElementById('form-offer-active').checked;

  if (!titleAr || !offerPrice) {
    alert('يرجى إدخال عنوان العرض وسعر العرض.');
    return;
  }

  if (adminState.editingOffer) {
    // تعديل
    adminState.editingOffer.titleAr = titleAr;
    adminState.editingOffer.descriptionAr = descAr;
    adminState.editingOffer.originalPrice = origPrice;
    adminState.editingOffer.offerPrice = offerPrice;
    adminState.editingOffer.badge = badge;
    adminState.editingOffer.expiryDate = expiry;
    adminState.editingOffer.imageUrl = imgUrl;
    adminState.editingOffer.isSample = isSample;
    adminState.editingOffer.isActive = isActive;
    showToast(`تم تحديث بيانات العرض بنجاح.`);
  } else {
    // إضافة جديد
    const newOffer = {
      id: 'off-' + Date.now(),
      titleAr: titleAr,
      titleEn: titleAr,
      descriptionAr: descAr,
      descriptionEn: '',
      imageUrl: imgUrl,
      badge: badge,
      originalPrice: origPrice,
      offerPrice: offerPrice,
      expiryDate: expiry,
      isSample: isSample,
      isActive: isActive
    };
    adminState.offers.unshift(newOffer);
    showToast(`تمت إضافة العرض الجديد بنجاح.`);
  }

  saveOffers();
  renderAdminOffers();
  closeOfferModal();
}

// ==========================================
// 6.2 إدارة أكواد الخصم (Coupons Management)
// ==========================================
function renderAdminCoupons() {
  const container = document.getElementById('admin-coupons-table-body');
  if (!container) return;

  if (adminState.coupons.length === 0) {
    container.innerHTML = '<tr><td colspan="5" style="text-align: center; padding: 25px; color: var(--admin-text-muted);">لا توجد أكواد خصم مسجلة حالياً.</td></tr>';
    return;
  }

  container.innerHTML = adminState.coupons.map(coupon => `
    <tr>
      <td>
        <strong style="color: var(--admin-secondary); font-size: 14px; letter-spacing: 1px;">${coupon.code}</strong>
      </td>
      <td>
        <span style="font-weight: 700;">${coupon.discountType === 'percent' ? `خصم ${coupon.value}%` : `خصم ${coupon.value} ج.م`}</span>
      </td>
      <td>
        <span>${coupon.minOrder ? `${coupon.minOrder} ج.م` : 'بدون حد أدنى'}</span>
      </td>
      <td>
        <button class="btn-admin-action ${coupon.isActive !== false ? 'success' : 'danger'}" onclick="toggleCouponActive('${coupon.code}')">
          ${coupon.isActive !== false ? 'مفعل' : 'معطل'}
        </button>
      </td>
      <td>
        <button class="btn-admin-action danger" onclick="deleteCoupon('${coupon.code}')" title="حذف الكود">
          <i class="fas fa-trash-alt"></i>
        </button>
      </td>
    </tr>
  `).join('');
}

function toggleCouponActive(code) {
  const c = adminState.coupons.find(item => item.code === code);
  if (c) {
    c.isActive = c.isActive === false ? true : false;
    saveCoupons();
    renderAdminCoupons();
    showToast(`تم تغيير حالة الكود ${code} إلى: ${c.isActive ? 'مفعل' : 'معطل'}`);
  }
}

function deleteCoupon(code) {
  if (confirm(`هل أنت متأكد من حذف كود الخصم "${code}"؟`)) {
    adminState.coupons = adminState.coupons.filter(item => item.code !== code);
    saveCoupons();
    renderAdminCoupons();
    showToast(`تم حذف كود الخصم بنجاح.`);
  }
}

function openAddCouponModal() {
  document.getElementById('form-coupon-code').value = '';
  document.getElementById('form-coupon-type').value = 'percent';
  document.getElementById('form-coupon-val').value = '10';
  document.getElementById('form-coupon-min').value = '100';
  document.getElementById('coupon-modal').style.display = 'flex';
}

function closeCouponModal() {
  document.getElementById('coupon-modal').style.display = 'none';
}

function handleSaveCoupon(e) {
  e.preventDefault();
  const code = document.getElementById('form-coupon-code').value.trim().toUpperCase();
  const type = document.getElementById('form-coupon-type').value;
  const val = parseFloat(document.getElementById('form-coupon-val').value) || 0;
  const minOrder = parseFloat(document.getElementById('form-coupon-min').value) || 0;

  if (!code || !val) {
    alert('يرجى كتابة كود الخصم وقيمته.');
    return;
  }

  // التحقق من عدم التكرار
  const existing = adminState.coupons.find(c => c.code.toUpperCase() === code);
  if (existing) {
    existing.discountType = type;
    existing.value = val;
    existing.minOrder = minOrder;
    existing.isActive = true;
    showToast(`تم تحديث كود الخصم ${code}.`);
  } else {
    adminState.coupons.unshift({
      code: code,
      discountType: type,
      value: val,
      minOrder: minOrder,
      isActive: true
    });
    showToast(`تمت إضافة كود الخصم (${code}) بنجاح.`);
  }

  saveCoupons();
  renderAdminCoupons();
  closeCouponModal();
}

// ==========================================
// 7. إعدادات المطعم (Restaurant Settings)
// ==========================================
function loadSettingsForm() {
  document.getElementById('setting-res-name-ar').value = adminState.settings.restaurantNameAr || '';
  document.getElementById('setting-res-name-en').value = adminState.settings.restaurantNameEn || '';
  document.getElementById('setting-phone-call').value = adminState.settings.phone || '';
  document.getElementById('setting-wa-number').value = adminState.settings.whatsApp || '';
  document.getElementById('setting-addr-ar').value = adminState.settings.addressAr || '';
  document.getElementById('setting-maps-link').value = adminState.settings.googleMapsUrl || '';
  document.getElementById('setting-del-fee').value = adminState.settings.defaultDeliveryFee || 20;
  document.getElementById('setting-min-order').value = adminState.settings.minimumOrderValue || 50;
  document.getElementById('setting-hours-ar').value = adminState.settings.openingHoursAr || '';
  document.getElementById('setting-announcement-ar').value = adminState.settings.announcementAr || '';

  // تحميل بيانات اسم المستخدم في بطاقة الأمان
  const creds = getAdminCredentials();
  const userInput = document.getElementById('setting-admin-username');
  if (userInput) userInput.value = creds.username;
}

function handleUpdateCredentials(e) {
  e.preventDefault();
  const newUsername = document.getElementById('setting-admin-username').value.trim();
  const newPassword = document.getElementById('setting-admin-password').value.trim();
  const confirmPassword = document.getElementById('setting-admin-password-confirm').value.trim();

  if (!newUsername) {
    alert('يرجى إدخال اسم المستخدم.');
    return;
  }

  if (newPassword) {
    if (newPassword.length < 6) {
      alert('كلمة المرور يجب أن تكون 6 أحرف أو أرقام على الأقل.');
      return;
    }
    if (newPassword !== confirmPassword) {
      alert('كلمة المرور الجديدة وتأكيدها غير متطابقين!');
      return;
    }
  }

  const creds = getAdminCredentials();
  creds.username = newUsername;
  if (newPassword) {
    creds.password = newPassword;
  }

  localStorage.setItem('alsheikh_admin_creds', JSON.stringify(creds));
  showToast('تم تحديث بيانات تسجيل دخول لوحة الإدارة بنجاح!');
  document.getElementById('setting-admin-password').value = '';
  document.getElementById('setting-admin-password-confirm').value = '';
}

function handleSaveSettings(e) {
  e.preventDefault();
  adminState.settings.restaurantNameAr = document.getElementById('setting-res-name-ar').value.trim();
  adminState.settings.restaurantNameEn = document.getElementById('setting-res-name-en').value.trim();
  adminState.settings.phone = document.getElementById('setting-phone-call').value.trim();
  adminState.settings.whatsApp = document.getElementById('setting-wa-number').value.trim();
  adminState.settings.addressAr = document.getElementById('setting-addr-ar').value.trim();
  adminState.settings.googleMapsUrl = document.getElementById('setting-maps-link').value.trim();
  adminState.settings.defaultDeliveryFee = parseFloat(document.getElementById('setting-del-fee').value) || 20;
  adminState.settings.minimumOrderValue = parseFloat(document.getElementById('setting-min-order').value) || 50;
  adminState.settings.openingHoursAr = document.getElementById('setting-hours-ar').value.trim();
  adminState.settings.announcementAr = document.getElementById('setting-announcement-ar').value.trim();

  saveSettings();
  showToast('تم حفظ كافة إعدادات المطعم بنجاح وتحديث الموقع.');
}

// ==========================================
// 8. إشعارات التوست وربط الأحداث
// ==========================================
function showToast(msg) {
  const toast = document.getElementById('admin-toast');
  if (!toast) return;
  toast.innerHTML = `<i class="fas fa-check-circle"></i> <span>${msg}</span>`;
  toast.style.display = 'flex';
  setTimeout(() => {
    toast.style.display = 'none';
  }, 4000);
}

function setupAdminListeners() {
  document.getElementById('admin-theme-btn')?.addEventListener('click', toggleAdminTheme);
  
  // شريط البحث في الطلبات
  document.getElementById('orders-search-input')?.addEventListener('input', (e) => {
    searchOrders(e.target.value);
  });

  // شريط البحث في المنتجات
  document.getElementById('products-search-input')?.addEventListener('input', (e) => {
    adminState.productsSearch = e.target.value.trim();
    renderProductsTable();
  });

  // فلتر التصنيفات في المنتجات
  document.getElementById('products-category-filter')?.addEventListener('change', (e) => {
    adminState.productsFilter = e.target.value;
    renderProductsTable();
  });

  // زر القائمة للموبايل
  document.getElementById('mobile-menu-btn')?.addEventListener('click', toggleAdminSidebar);
  document.getElementById('sidebar-backdrop')?.addEventListener('click', closeAdminSidebar);
}

// ==========================================
// دوال إدارة القائمة الجانبية للموبايل
// ==========================================
function openAdminSidebar() {
  document.querySelector('.admin-sidebar')?.classList.add('mobile-open');
  document.getElementById('sidebar-backdrop')?.classList.add('active');
}

function closeAdminSidebar() {
  document.querySelector('.admin-sidebar')?.classList.remove('mobile-open');
  document.getElementById('sidebar-backdrop')?.classList.remove('active');
}

function toggleAdminSidebar() {
  const sidebar = document.querySelector('.admin-sidebar');
  if (sidebar && sidebar.classList.contains('mobile-open')) {
    closeAdminSidebar();
  } else {
    openAdminSidebar();
  }
}
