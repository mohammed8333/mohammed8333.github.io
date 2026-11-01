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

  // تحميل الطلبات
  const savedOrders = localStorage.getItem('alsheikh_orders');
  if (savedOrders) {
    try {
      adminState.orders = JSON.parse(savedOrders);
    } catch (e) {
      adminState.orders = [];
    }
  } else {
    adminState.orders = [];
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
    offers: 'إدارة العروض والخصومات والكوبونات',
    settings: 'إعدادات المطعم وبيانات الاتصال'
  };
  const topTitle = document.getElementById('topbar-view-title');
  if (topTitle) topTitle.textContent = titles[viewName] || 'لوحة التحكم';

  // تحميل بيانات المشهد
  if (viewName === 'overview') renderOverviewStats();
  if (viewName === 'orders') renderOrdersTable();
  if (viewName === 'products') renderProductsTable();
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
// 5. إدارة ومتابعة الطلبات (Orders Management)
// ==========================================
function renderOrdersTable() {
  const container = document.getElementById('orders-table-body');
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
      (o.area && o.area.toLowerCase().includes(q))
    );
  }

  if (filtered.length === 0) {
    container.innerHTML = `
      <tr>
        <td colspan="7" style="text-align: center; padding: 50px 20px; color: var(--admin-text-muted);">
          <i class="fas fa-clipboard-list" style="font-size: 40px; margin-bottom: 12px; opacity: 0.4;"></i>
          <p style="font-size: 15px; font-weight: 700;">لا توجد طلبات تطابق معايير البحث أو التصفية الحالية.</p>
        </td>
      </tr>
    `;
    return;
  }

  container.innerHTML = filtered.map(order => {
    const itemsSummary = order.items.map(i => {
      let desc = `${i.name} (x${i.quantity})`;
      if (i.size) desc += ` [${i.size}]`;
      if (i.extras && i.extras.length > 0) desc += ` +${i.extras.join(', ')}`;
      return desc;
    }).join('<br>');

    // تنظيف رقم هاتف العميل للتواصل عبر واتساب
    let cleanPhone = order.customerPhone.replace(/[^0-9]/g, '');
    if (cleanPhone.startsWith('01')) cleanPhone = '20' + cleanPhone.substring(1);

    const waCustomerUrl = `https://wa.me/${cleanPhone}?text=${encodeURIComponent(`مرحباً أستاذ ${order.customerName}، معكم إدارة مطعم بيتزا أولاد الشيخ بخصوص طلبكم رقم ${order.orderRef}...`)}`;

    return `
      <tr>
        <td>
          <strong style="color: var(--admin-primary); font-size: 14px;">${order.orderRef}</strong>
          <div style="font-size: 11.5px; color: var(--admin-text-muted);">${new Date(order.createdAt).toLocaleString('ar-EG')}</div>
        </td>
        <td>
          <div style="font-weight: 800;">${order.customerName}</div>
          <div style="font-size: 12.5px; color: var(--admin-text-muted);">${order.customerPhone}</div>
          <div style="display: flex; gap: 6px; margin-top: 4px;">
            <a href="tel:${order.customerPhone}" class="btn-admin-action ghost" style="padding: 2px 6px; font-size: 11px;" title="اتصال">
              <i class="fas fa-phone-alt"></i>
            </a>
            <a href="${waCustomerUrl}" target="_blank" class="btn-admin-action success" style="padding: 2px 6px; font-size: 11px;" title="واتساب">
              <i class="fab fa-whatsapp"></i>
            </a>
          </div>
        </td>
        <td>
          <div style="font-weight: 700;">${order.orderType === 'delivery' ? '🛵 توصيل' : '🛍️ استلام'}</div>
          ${order.area ? `<div style="font-size: 11.5px; color: var(--admin-text-muted);">${order.area}</div>` : ''}
          ${order.address ? `<div style="font-size: 11px; max-width: 180px; color: var(--admin-text-muted);">${order.address}</div>` : ''}
          ${order.locationUrl ? `<a href="${order.locationUrl}" target="_blank" style="color: var(--admin-primary); font-size: 11px; text-decoration: underline;"><i class="fas fa-map-marker-alt"></i> موقع GPS</a>` : ''}
        </td>
        <td>
          <div style="font-size: 12px; line-height: 1.5; max-height: 80px; overflow-y: auto;">
            ${itemsSummary}
          </div>
          ${order.instructions ? `<div style="font-size: 11px; color: #b45309; margin-top: 4px;">ملاحظة: ${order.instructions}</div>` : ''}
        </td>
        <td>
          <strong style="font-size: 15px; color: var(--admin-primary);">${order.total} ج.م</strong>
          <div style="font-size: 11px; color: var(--admin-text-muted);">${order.paymentMethod || 'كاش'}</div>
        </td>
        <td>
          <select class="form-control" style="padding: 6px 10px; font-size: 12.5px; font-weight: 700;" onchange="updateOrderStatus('${order.orderRef}', this.value)">
            <option value="Pending" ${order.status === 'Pending' ? 'selected' : ''}>⏳ قيد المراجعة</option>
            <option value="Confirmed" ${order.status === 'Confirmed' ? 'selected' : ''}>✔️ تم التأكيد</option>
            <option value="Preparing" ${order.status === 'Preparing' ? 'selected' : ''}>🔥 قيد التجهيز</option>
            <option value="OutForDelivery" ${order.status === 'OutForDelivery' ? 'selected' : ''}>🛵 في الطريق</option>
            <option value="Delivered" ${order.status === 'Delivered' ? 'selected' : ''}>✅ تم التسليم</option>
            <option value="Cancelled" ${order.status === 'Cancelled' ? 'selected' : ''}>❌ ملغي</option>
          </select>
        </td>
        <td>
          <button class="btn-admin-action danger" onclick="deleteOrder('${order.orderRef}')" title="حذف الطلب">
            <i class="fas fa-trash-alt"></i>
          </button>
        </td>
      </tr>
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
    showToast('تم حذف الطلب بنجاح.');
  }
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
  adminState.editingProduct = null;
  document.getElementById('modal-product-title').textContent = 'إضافة صنف جديد للقائمة';
  document.getElementById('form-product-name-ar').value = '';
  document.getElementById('form-product-name-en').value = '';
  document.getElementById('form-product-cat').value = 'cat-1';
  document.getElementById('form-product-price').value = '100';
  document.getElementById('form-product-desc-ar').value = '';
  document.getElementById('form-product-img').value = '';
  document.getElementById('form-product-sample').checked = false;
  document.getElementById('form-product-avail').checked = true;

  document.getElementById('product-modal').style.display = 'flex';
}

function openEditProductModal(prodId) {
  const p = adminState.products.find(item => item.id === prodId);
  if (!p) return;

  adminState.editingProduct = p;
  document.getElementById('modal-product-title').textContent = `تعديل صنف: ${p.nameAr}`;
  document.getElementById('form-product-name-ar').value = p.nameAr || '';
  document.getElementById('form-product-name-en').value = p.nameEn || '';
  document.getElementById('form-product-cat').value = p.categoryId || 'cat-1';
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
