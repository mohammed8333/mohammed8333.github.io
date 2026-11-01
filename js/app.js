// ==========================================================================
// تطبيق موقع بيتزا أولاد الشيخ - Pizza Awlad Alsheikh Web Application
// منطق التشغيل الكامل: السلة، المنتجات، التخصيص، الواتساب، ولوحة التحكم
// ==========================================================================

// الحالة العامة للتطبيق (State)
const state = {
  lang: localStorage.getItem('alsheikh_lang') || 'ar',
  theme: localStorage.getItem('alsheikh_theme') || 'light',
  products: [],
  offers: [],
  coupons: [],
  appliedCoupon: null,
  categories: DEFAULT_CATEGORIES,
  settings: { ...DEFAULT_SETTINGS },
  selectedCategory: 'all',
  searchQuery: '',
  cart: JSON.parse(localStorage.getItem('alsheikh_cart') || '[]'),
  orderType: 'delivery', // 'delivery' | 'takeaway'
  userLocation: null,
  activeProductForModal: null,
  isAdminLoggedIn: sessionStorage.getItem('alsheikh_admin_auth') === 'true',
  orders: JSON.parse(localStorage.getItem('alsheikh_orders') || '[]')
};

// ==========================================
// 1. تهيئة التطبيق عند تحميل الصفحة
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initLanguage();
  loadSettings();
  loadOffers();
  loadCoupons();
  loadProductsSync();
  renderOffers();
  renderCategories();
  renderProducts();
  updateCartUI();
  setupEventListeners();
  renderDeliveryAreas();
  // فحص الـ API في الخلفية بدون حجب واجهة المستخدم
  checkApiProductsInBackground();
});

// تهيئة الوضع الليلي / النهاري
function initTheme() {
  document.documentElement.setAttribute('data-theme', state.theme);
  const themeBtn = document.getElementById('theme-toggle-btn');
  if (themeBtn) {
    themeBtn.innerHTML = state.theme === 'dark' 
      ? '<i class="fas fa-sun"></i>' 
      : '<i class="fas fa-moon"></i>';
  }
}

function toggleTheme() {
  state.theme = state.theme === 'dark' ? 'light' : 'dark';
  localStorage.setItem('alsheikh_theme', state.theme);
  initTheme();
}

// تهيئة اللغة والاتجاه (RTL / LTR)
function initLanguage() {
  document.documentElement.lang = state.lang;
  document.documentElement.dir = state.lang === 'ar' ? 'rtl' : 'ltr';
  const langBtn = document.getElementById('lang-toggle-btn');
  if (langBtn) {
    langBtn.textContent = state.lang === 'ar' ? 'EN' : 'عربي';
  }
}

function toggleLanguage() {
  state.lang = state.lang === 'ar' ? 'en' : 'ar';
  localStorage.setItem('alsheikh_lang', state.lang);
  initLanguage();
  renderCategories();
  renderProducts();
  updateCartUI();
  updateStaticTexts();
}

// تحديث النصوص الثابتة عند تغيير اللغة
function updateStaticTexts() {
  const isAr = state.lang === 'ar';
  document.title = isAr ? 'بيتزا أولاد الشيخ | إمبابة' : 'Pizza Awlad Alsheikh | Imbaba';
  
  const announcementEl = document.getElementById('announcement-text');
  if (announcementEl) {
    announcementEl.textContent = isAr ? state.settings.announcementAr : state.settings.announcementEn;
  }
}

// تحميل الإعدادات من التخزين المحلي أو الافتراضي
function loadSettings() {
  const savedSettings = localStorage.getItem('alsheikh_settings');
  if (savedSettings) {
    try {
      state.settings = { ...DEFAULT_SETTINGS, ...JSON.parse(savedSettings) };
    } catch (e) {
      state.settings = { ...DEFAULT_SETTINGS };
    }
  }
  updateStaticTexts();
}

// تحميل العروض الترويجية
function loadOffers() {
  const savedOffers = localStorage.getItem('alsheikh_offers');
  if (savedOffers) {
    try {
      state.offers = JSON.parse(savedOffers);
    } catch (e) {
      state.offers = [...DEFAULT_OFFERS];
    }
  } else {
    state.offers = [...DEFAULT_OFFERS];
  }
}

// تحميل كوبونات الخصم
function loadCoupons() {
  const savedCoupons = localStorage.getItem('alsheikh_coupons');
  if (savedCoupons) {
    try {
      state.coupons = JSON.parse(savedCoupons);
    } catch (e) {
      state.coupons = [...DEFAULT_COUPONS];
    }
  } else {
    state.coupons = [...DEFAULT_COUPONS];
  }
}

// تحميل المنتجات فورياً وبشكل متزامن لسرعة الإقلاع على الموبايل
function loadProductsSync() {
  const savedProducts = localStorage.getItem('alsheikh_products');
  if (savedProducts) {
    try {
      state.products = JSON.parse(savedProducts);
      return;
    } catch (e) {
      state.products = [...DEFAULT_PRODUCTS];
    }
  } else {
    state.products = [...DEFAULT_PRODUCTS];
  }
}

// فحص اختياري للـ API في الخلفية بدون تأخير فتح الصفحة
async function checkApiProductsInBackground() {
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 2000);
    const res = await fetch('/api/products', { signal: controller.signal });
    clearTimeout(timeoutId);
    if (res.ok) {
      const data = await res.json();
      if (Array.isArray(data) && data.length > 0) {
        state.products = data;
        renderProducts();
      }
    }
  } catch (err) {
    // يعمل على وضع Offline / GitHub Pages
  }
}

// ==========================================
// 1.1 عرض العروض الترويجية والخصومات
// ==========================================
function renderOffers() {
  const container = document.getElementById('offers-container');
  if (!container) return;

  const isAr = state.lang === 'ar';
  const activeOffers = state.offers.filter(o => o.isActive !== false);

  if (activeOffers.length === 0) {
    container.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-muted);">
        <i class="fas fa-gift" style="font-size: 36px; margin-bottom: 10px; opacity: 0.5;"></i>
        <p>${isAr ? 'ترقبوا أقوى عروض أولاد الشيخ قريباً!' : 'Stay tuned for exclusive offers soon!'}</p>
      </div>
    `;
    return;
  }

  container.innerHTML = activeOffers.map(offer => {
    const title = isAr ? offer.titleAr : offer.titleEn;
    const desc = isAr ? offer.descriptionAr : offer.descriptionEn;
    const savings = offer.originalPrice ? Math.round(offer.originalPrice - offer.offerPrice) : 0;
    const sampleBadge = offer.isSample ? `
      <div class="unverified-badge" style="margin-bottom: 8px;">
        <i class="fas fa-info-circle"></i>
        <span>${isAr ? 'عينة عرض - تخضع لاعتماد الإدارة' : 'Sample Deal - Pending Admin'}</span>
      </div>
    ` : '';

    return `
      <div class="offer-card">
        <div class="offer-card-thumb-wrap">
          <img src="${offer.imageUrl || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800'}" alt="${title}" class="offer-card-img" loading="lazy">
          ${offer.badge ? `<span class="offer-ribbon">${offer.badge}</span>` : ''}
        </div>
        <div class="offer-card-body">
          ${sampleBadge}
          <h3 class="offer-title">${title}</h3>
          <p class="offer-desc">${desc}</p>
          <div class="offer-price-row">
            <span class="offer-current-price">${offer.offerPrice} <small style="font-size: 13px;">${isAr ? 'ج.م' : 'EGP'}</small></span>
            ${offer.originalPrice ? `<span class="offer-old-price">${offer.originalPrice} ج.م</span>` : ''}
            ${savings > 0 ? `<span class="offer-save-tag">${isAr ? `توفير ${savings} ج.م` : `Save ${savings} EGP`}</span>` : ''}
          </div>
          <button class="btn-add-offer" onclick="addOfferToCart('${offer.id}')">
            <i class="fas fa-cart-plus"></i>
            <span>${isAr ? 'أضف العرض للسلة' : 'Add Deal to Cart'}</span>
          </button>
        </div>
      </div>
    `;
  }).join('');
}

function addOfferToCart(offerId) {
  const offer = state.offers.find(o => o.id === offerId);
  if (!offer) return;

  const isAr = state.lang === 'ar';
  const cartItem = {
    cartItemId: 'offer_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
    productId: offer.id,
    nameAr: `[عرض] ${offer.titleAr}`,
    nameEn: `[Offer] ${offer.titleEn}`,
    imageUrl: offer.imageUrl,
    size: null,
    extras: [],
    quantity: 1,
    unitPrice: offer.offerPrice,
    notes: offer.badge ? `عرض خاص (${offer.badge})` : 'عرض خاص',
    isSample: offer.isSample,
    isOffer: true
  };

  state.cart.push(cartItem);
  saveCart();
  updateCartUI();
  openCartDrawer();
}

function calculateDiscount(subtotal) {
  if (!state.appliedCoupon) return 0;
  const coupon = state.appliedCoupon;
  if (subtotal < (coupon.minOrder || 0)) return 0;

  if (coupon.discountType === 'percent') {
    return Math.round(subtotal * (coupon.value / 100));
  } else {
    return Math.min(coupon.value, subtotal);
  }
}

function applyCouponCode() {
  const isAr = state.lang === 'ar';
  const input = document.getElementById('cart-coupon-input');
  if (!input) return;
  const code = input.value.trim().toUpperCase();

  if (!code) {
    alert(isAr ? 'يرجى إدخال كود الخصم.' : 'Please enter coupon code.');
    return;
  }

  const subtotal = state.cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
  const coupon = state.coupons.find(c => c.code.toUpperCase() === code && c.isActive !== false);

  if (!coupon) {
    alert(isAr ? 'كود الخصم غير صحيح أو غير متاح حالياً.' : 'Invalid or inactive coupon code.');
    return;
  }

  if (coupon.minOrder && subtotal < coupon.minOrder) {
    alert(isAr ? `هذا الكوبون يتطلب طلباً بقيمة ${coupon.minOrder} ج.م على الأقل.` : `This coupon requires minimum order of ${coupon.minOrder} EGP.`);
    return;
  }

  state.appliedCoupon = coupon;
  updateCartUI();

  const msgEl = document.getElementById('coupon-applied-msg');
  if (msgEl) {
    msgEl.style.display = 'block';
    msgEl.textContent = isAr 
      ? `✔️ تم تطبيق الكود (${coupon.code}) بنجاح!` 
      : `✔️ Coupon (${coupon.code}) applied!`;
  }
}

// ==========================================
// 2. عرض التصنيفات والفلترة
// ==========================================
function renderCategories() {
  const container = document.getElementById('categories-container');
  if (!container) return;

  const isAr = state.lang === 'ar';
  let html = `
    <button class="cat-pill ${state.selectedCategory === 'all' ? 'active' : ''}" onclick="selectCategory('all')">
      <i class="fas fa-utensils"></i>
      <span>${isAr ? 'كل القائمة' : 'All Menu'}</span>
    </button>
  `;

  state.categories.forEach(cat => {
    const active = state.selectedCategory === cat.id ? 'active' : '';
    const name = isAr ? cat.nameAr : cat.nameEn;
    html += `
      <button class="cat-pill ${active}" onclick="selectCategory('${cat.id}')">
        <i class="fas ${cat.icon || 'fa-tag'}"></i>
        <span>${name}</span>
      </button>
    `;
  });

  container.innerHTML = html;
}

function selectCategory(catId) {
  state.selectedCategory = catId;
  renderCategories();
  renderProducts();
}

function handleSearch(query) {
  state.searchQuery = query.trim().toLowerCase();
  renderProducts();
}

// ==========================================
// 3. عرض المنتجات
// ==========================================
function renderProducts() {
  const container = document.getElementById('products-container');
  if (!container) return;

  const isAr = state.lang === 'ar';
  let filtered = state.products.filter(p => p.isAvailable !== false);

  if (state.selectedCategory !== 'all') {
    filtered = filtered.filter(p => p.categoryId === state.selectedCategory);
  }

  if (state.searchQuery) {
    filtered = filtered.filter(p => {
      const matchAr = p.nameAr && p.nameAr.toLowerCase().includes(state.searchQuery);
      const matchEn = p.nameEn && p.nameEn.toLowerCase().includes(state.searchQuery);
      const descAr = p.descriptionAr && p.descriptionAr.toLowerCase().includes(state.searchQuery);
      const descEn = p.descriptionEn && p.descriptionEn.toLowerCase().includes(state.searchQuery);
      return matchAr || matchEn || descAr || descEn;
    });
  }

  if (filtered.length === 0) {
    container.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px;">
        <i class="fas fa-pizza-slice" style="font-size: 48px; color: var(--text-muted); margin-bottom: 15px;"></i>
        <h3 style="font-weight: 800; font-size: 18px;">${isAr ? 'لا توجد منتجات مطابقة للبحث' : 'No products found'}</h3>
        <p style="color: var(--text-muted); font-size: 14px; margin-top: 5px;">${isAr ? 'جرب البحث بكلمة أخرى أو اختر تصنيفاً مختلفاً' : 'Try searching with another keyword or pick another category'}</p>
      </div>
    `;
    return;
  }

  container.innerHTML = filtered.map(prod => {
    const title = isAr ? prod.nameAr : prod.nameEn;
    const desc = isAr ? prod.descriptionAr : prod.descriptionEn;
    const sizes = prod.sizes || [];
    const minPrice = sizes.length > 0 ? Math.min(...sizes.map(s => s.price)) : prod.basePrice;

    // علامة العينة التجريبية لحماية الشفافية مع العميل
    const sampleBadgeHtml = prod.isSample ? `
      <div class="unverified-badge" title="${isAr ? 'عينة للتجربة تتطلب اعتماد الإدارة للأسعار الرسمية' : 'Sample record pending official admin verification'}">
        <i class="fas fa-info-circle"></i>
        <span>${isAr ? 'عينة تجريبية - تتطلب تأكيد الإدارة' : 'Sample - Pending Admin Confirmation'}</span>
      </div>
    ` : '';

    const badgesHtml = `
      <div class="product-badge-stack">
        ${prod.isFeatured ? `<span class="badge-featured">${isAr ? 'مميز' : 'Featured'}</span>` : ''}
        ${prod.isBestSeller ? `<span class="badge-bestseller">${isAr ? 'الأكثر طلباً' : 'Best Seller'}</span>` : ''}
      </div>
    `;

    const sizesPreviewHtml = sizes.length > 0 ? `
      <div class="product-sizes-preview">
        ${sizes.map(s => `<span class="size-mini-chip">${isAr ? s.nameAr : s.nameEn} (${s.price} ج.م)</span>`).join('')}
      </div>
    ` : '';

    return `
      <div class="product-card">
        <div class="product-thumb-wrap">
          <img src="${prod.imageUrl || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800'}" alt="${title}" class="product-thumb" loading="lazy">
          ${badgesHtml}
        </div>
        <div class="product-info">
          ${sampleBadgeHtml}
          <h3 class="product-title">${title}</h3>
          <p class="product-desc">${desc}</p>
          ${sizesPreviewHtml}
          <div class="product-footer">
            <div>
              <div class="product-price-label">${isAr ? (sizes.length > 1 ? 'يبدأ من' : 'السعر') : (sizes.length > 1 ? 'Starts from' : 'Price')}</div>
              <div class="product-price">${minPrice} <span style="font-size: 13px;">${isAr ? 'ج.م' : 'EGP'}</span></div>
            </div>
            <button class="btn-customize" onclick="openProductModal('${prod.id}')">
              <i class="fas fa-plus"></i>
              <span>${isAr ? 'تخصيص وإضافة' : 'Customize & Add'}</span>
            </button>
          </div>
        </div>
      </div>
    `;
  }).join('');
}

// ==========================================
// 4. نافذة تخصيص المنتج المنبثقة (Modal)
// ==========================================
function openProductModal(productId) {
  const product = state.products.find(p => p.id === productId);
  if (!product) return;

  state.activeProductForModal = {
    product: product,
    selectedSize: product.sizes && product.sizes.length > 0 ? (product.sizes.find(s => s.isDefault) || product.sizes[0]) : null,
    selectedExtras: [],
    quantity: 1,
    notes: ''
  };

  renderModalContent();
  document.getElementById('product-modal').classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeProductModal() {
  document.getElementById('product-modal').classList.remove('active');
  document.body.style.overflow = '';
  state.activeProductForModal = null;
}

function renderModalContent() {
  const modalData = state.activeProductForModal;
  if (!modalData) return;

  const prod = modalData.product;
  const isAr = state.lang === 'ar';
  const title = isAr ? prod.nameAr : prod.nameEn;
  const desc = isAr ? prod.descriptionAr : prod.descriptionEn;

  document.getElementById('modal-img').src = prod.imageUrl;
  document.getElementById('modal-title').textContent = title;
  document.getElementById('modal-desc').textContent = desc;

  // إشعار العينة في المودال
  const sampleNotice = document.getElementById('modal-sample-badge');
  if (sampleNotice) {
    sampleNotice.style.display = prod.isSample ? 'flex' : 'none';
    sampleNotice.innerHTML = `
      <i class="fas fa-exclamation-triangle"></i>
      <span>${isAr 
        ? 'تنبيه: هذا الصنف مسجل كعينة تجريبية قابلة للتعديل وبانتظار اعتماد الأسعار النهائية من إدارة المطعم.' 
        : 'Notice: This item is a sample record and requires restaurant management confirmation.'}</span>
    `;
  }

  // خيارات الأحجام
  const sizesContainer = document.getElementById('modal-sizes-container');
  if (prod.sizes && prod.sizes.length > 0) {
    sizesContainer.style.display = 'block';
    document.getElementById('modal-sizes-list').innerHTML = prod.sizes.map((size, idx) => {
      const isChecked = modalData.selectedSize && modalData.selectedSize.id === size.id;
      return `
        <label class="option-card-label" style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px;">
          <div style="display: flex; align-items: center; gap: 10px;">
            <input type="radio" name="modal_size" value="${size.id}" ${isChecked ? 'checked' : ''} onchange="onModalSizeChange('${size.id}')">
            <span>${isAr ? size.nameAr : size.nameEn}</span>
          </div>
          <strong style="color: var(--primary);">${size.price} ${isAr ? 'ج.م' : 'EGP'}</strong>
        </label>
      `;
    }).join('');
  } else {
    sizesContainer.style.display = 'none';
  }

  // خيارات الإضافات
  const extrasContainer = document.getElementById('modal-extras-container');
  if (prod.extras && prod.extras.length > 0) {
    extrasContainer.style.display = 'block';
    document.getElementById('modal-extras-list').innerHTML = prod.extras.map(extra => {
      const isChecked = modalData.selectedExtras.some(e => e.id === extra.id);
      return `
        <label class="option-card-label" style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px;">
          <div style="display: flex; align-items: center; gap: 10px;">
            <input type="checkbox" value="${extra.id}" ${isChecked ? 'checked' : ''} onchange="onModalExtraToggle('${extra.id}')">
            <span>${isAr ? extra.nameAr : extra.nameEn}</span>
          </div>
          <strong style="color: var(--secondary);">+${extra.price} ${isAr ? 'ج.م' : 'EGP'}</strong>
        </label>
      `;
    }).join('');
  } else {
    extrasContainer.style.display = 'none';
  }

  // تحديث حقل الملاحظات والكمية
  document.getElementById('modal-notes').value = modalData.notes || '';
  document.getElementById('modal-qty-val').textContent = modalData.quantity;

  updateModalPrice();
}

function onModalSizeChange(sizeId) {
  if (!state.activeProductForModal) return;
  const size = state.activeProductForModal.product.sizes.find(s => s.id === sizeId);
  if (size) {
    state.activeProductForModal.selectedSize = size;
    updateModalPrice();
  }
}

function onModalExtraToggle(extraId) {
  if (!state.activeProductForModal) return;
  const extra = state.activeProductForModal.product.extras.find(e => e.id === extraId);
  if (!extra) return;

  const idx = state.activeProductForModal.selectedExtras.findIndex(e => e.id === extraId);
  if (idx > -1) {
    state.activeProductForModal.selectedExtras.splice(idx, 1);
  } else {
    state.activeProductForModal.selectedExtras.push(extra);
  }
  updateModalPrice();
}

function changeModalQty(delta) {
  if (!state.activeProductForModal) return;
  const newQty = state.activeProductForModal.quantity + delta;
  if (newQty >= 1 && newQty <= 20) {
    state.activeProductForModal.quantity = newQty;
    document.getElementById('modal-qty-val').textContent = newQty;
    updateModalPrice();
  }
}

function updateModalPrice() {
  const modalData = state.activeProductForModal;
  if (!modalData) return;

  const base = modalData.selectedSize ? modalData.selectedSize.price : (modalData.product.basePrice || 0);
  const extrasTotal = modalData.selectedExtras.reduce((sum, e) => sum + e.price, 0);
  const unitPrice = base + extrasTotal;
  const totalPrice = unitPrice * modalData.quantity;

  const isAr = state.lang === 'ar';
  document.getElementById('modal-total-price').textContent = `${totalPrice} ${isAr ? 'ج.م' : 'EGP'}`;
}

function addModalItemToCart() {
  const modalData = state.activeProductForModal;
  if (!modalData) return;

  modalData.notes = document.getElementById('modal-notes').value.trim();

  const basePrice = modalData.selectedSize ? modalData.selectedSize.price : (modalData.product.basePrice || 0);
  const extrasPrice = modalData.selectedExtras.reduce((sum, e) => sum + e.price, 0);
  const unitPrice = basePrice + extrasPrice;

  const cartItem = {
    cartItemId: 'item_' + Date.now() + '_' + Math.random().toString(36).substr(2, 4),
    productId: modalData.product.id,
    nameAr: modalData.product.nameAr,
    nameEn: modalData.product.nameEn,
    imageUrl: modalData.product.imageUrl,
    size: modalData.selectedSize ? {
      id: modalData.selectedSize.id,
      nameAr: modalData.selectedSize.nameAr,
      nameEn: modalData.selectedSize.nameEn,
      price: modalData.selectedSize.price
    } : null,
    extras: modalData.selectedExtras.map(e => ({
      id: e.id,
      nameAr: e.nameAr,
      nameEn: e.nameEn,
      price: e.price
    })),
    quantity: modalData.quantity,
    unitPrice: unitPrice,
    notes: modalData.notes,
    isSample: modalData.product.isSample
  };

  state.cart.push(cartItem);
  saveCart();
  updateCartUI();
  closeProductModal();
  openCartDrawer();
}

// ==========================================
// 5. إدارة عربة التسوق (Cart Drawer)
// ==========================================
function saveCart() {
  localStorage.setItem('alsheikh_cart', JSON.stringify(state.cart));
}

function openCartDrawer() {
  document.getElementById('cart-drawer').classList.add('active');
  document.getElementById('drawer-backdrop').classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeCartDrawer() {
  document.getElementById('cart-drawer').classList.remove('active');
  document.getElementById('drawer-backdrop').classList.remove('active');
  document.body.style.overflow = '';
}

function setOrderType(type) {
  state.orderType = type;
  document.querySelectorAll('.order-type-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.type === type);
  });
  updateCartUI();
}

function updateCartUI() {
  const isAr = state.lang === 'ar';
  const badge = document.getElementById('nav-cart-badge');
  const totalCount = state.cart.reduce((sum, item) => sum + item.quantity, 0);
  if (badge) badge.textContent = totalCount;

  const container = document.getElementById('cart-items-container');
  const footer = document.getElementById('cart-footer-content');
  if (!container || !footer) return;

  if (state.cart.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 40px 15px; color: var(--text-muted);">
        <i class="fas fa-shopping-basket" style="font-size: 50px; margin-bottom: 15px; opacity: 0.4;"></i>
        <h4 style="font-weight: 800; font-size: 16px;">${isAr ? 'عربة التسوق فارغة' : 'Your cart is empty'}</h4>
        <p style="font-size: 13px; margin-top: 6px;">${isAr ? 'أضف ألذ أنواع البيتزا والكريب والحواوشي لتبدأ طلبك!' : 'Add delicious pizza, crepes, and hawawshi to start ordering!'}</p>
      </div>
    `;
    footer.style.display = 'none';
    return;
  }

  footer.style.display = 'block';

  container.innerHTML = state.cart.map(item => {
    const title = isAr ? item.nameAr : item.nameEn;
    const sizeStr = item.size ? `${isAr ? 'الحجم' : 'Size'}: ${isAr ? item.size.nameAr : item.size.nameEn}` : '';
    const extrasStr = item.extras && item.extras.length > 0 
      ? `${isAr ? 'إضافات' : 'Extras'}: ${item.extras.map(e => isAr ? e.nameAr : e.nameEn).join(', ')}` 
      : '';
    const notesStr = item.notes ? `${isAr ? 'ملاحظة' : 'Note'}: ${item.notes}` : '';

    return `
      <div class="cart-item-row">
        <img src="${item.imageUrl || 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200'}" alt="${title}" class="cart-item-img">
        <div class="cart-item-details">
          <div style="display: flex; justify-content: space-between; align-items: flex-start;">
            <h4 class="cart-item-title">${title}</h4>
            <button onclick="removeCartItem('${item.cartItemId}')" style="background: none; color: #ef4444; font-size: 14px; padding: 2px;" title="${isAr ? 'حذف' : 'Remove'}">
              <i class="fas fa-trash-alt"></i>
            </button>
          </div>
          ${sizeStr ? `<div class="cart-item-meta">${sizeStr}</div>` : ''}
          ${extrasStr ? `<div class="cart-item-meta">${extrasStr}</div>` : ''}
          ${notesStr ? `<div class="cart-item-meta" style="color: var(--secondary);">${notesStr}</div>` : ''}
          <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 8px;">
            <div class="cart-item-price">${item.unitPrice * item.quantity} ${isAr ? 'ج.م' : 'EGP'}</div>
            <div class="qty-counter" style="padding: 2px 6px;">
              <button class="qty-btn" style="width: 24px; height: 24px; font-size: 13px;" onclick="changeCartItemQty('${item.cartItemId}', -1)">-</button>
              <span style="font-size: 13px; font-weight: 800; min-width: 16px; text-align: center;">${item.quantity}</span>
              <button class="qty-btn" style="width: 24px; height: 24px; font-size: 13px;" onclick="changeCartItemQty('${item.cartItemId}', 1)">+</button>
            </div>
          </div>
        </div>
      </div>
    `;
  }).join('');

  // الحسابات المالية مع احتساب الخصومات والكوبونات
  const subtotal = state.cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
  const discount = calculateDiscount(subtotal);
  const deliveryFee = state.orderType === 'delivery' ? (state.settings.defaultDeliveryFee || 20) : 0;
  const total = Math.max(0, subtotal - discount + deliveryFee);

  document.getElementById('cart-subtotal').textContent = `${subtotal} ${isAr ? 'ج.م' : 'EGP'}`;
  
  const discountRow = document.getElementById('cart-discount-row');
  const discountFee = document.getElementById('cart-discount-fee');
  if (discountRow && discountFee) {
    if (discount > 0) {
      discountRow.style.display = 'flex';
      discountFee.textContent = `-${discount} ${isAr ? 'ج.م' : 'EGP'}`;
    } else {
      discountRow.style.display = 'none';
    }
  }

  document.getElementById('cart-delivery-fee').textContent = state.orderType === 'delivery' 
    ? `${deliveryFee} ${isAr ? 'ج.م' : 'EGP'}` 
    : (isAr ? 'مجاناً (استلام من المحل)' : 'Free (Pickup)');
  document.getElementById('cart-total').textContent = `${total} ${isAr ? 'ج.م' : 'EGP'}`;
}

function changeCartItemQty(cartItemId, delta) {
  const item = state.cart.find(i => i.cartItemId === cartItemId);
  if (!item) return;

  item.quantity += delta;
  if (item.quantity <= 0) {
    state.cart = state.cart.filter(i => i.cartItemId !== cartItemId);
  }
  saveCart();
  updateCartUI();
}

function removeCartItem(cartItemId) {
  state.cart = state.cart.filter(i => i.cartItemId !== cartItemId);
  saveCart();
  updateCartUI();
}

function clearCart() {
  state.cart = [];
  saveCart();
  updateCartUI();
}

// ==========================================
// 6. شاشة الدفع والطلب (Checkout)
// ==========================================
function openCheckoutModal() {
  if (state.cart.length === 0) return;
  closeCartDrawer();

  // تعبئة البيانات في مودال الدفع مع الخصم
  const subtotal = state.cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
  const discount = calculateDiscount(subtotal);
  const deliveryFee = state.orderType === 'delivery' ? (state.settings.defaultDeliveryFee || 20) : 0;
  const total = Math.max(0, subtotal - discount + deliveryFee);
  const isAr = state.lang === 'ar';

  document.getElementById('checkout-subtotal').textContent = `${subtotal} ${isAr ? 'ج.م' : 'EGP'}`;
  
  const discountRow = document.getElementById('checkout-discount-row');
  const discountFee = document.getElementById('checkout-discount-fee');
  if (discountRow && discountFee) {
    if (discount > 0) {
      discountRow.style.display = 'flex';
      discountFee.textContent = `-${discount} ${isAr ? 'ج.م' : 'EGP'}`;
    } else {
      discountRow.style.display = 'none';
    }
  }

  document.getElementById('checkout-delivery-fee').textContent = `${deliveryFee} ${isAr ? 'ج.م' : 'EGP'}`;
  document.getElementById('checkout-total').textContent = `${total} ${isAr ? 'ج.م' : 'EGP'}`;

  // تعديل ظهور حقول العنوان حسب نوع الطلب
  const addressFields = document.getElementById('checkout-delivery-address-group');
  if (addressFields) {
    addressFields.style.display = state.orderType === 'delivery' ? 'block' : 'none';
  }

  document.getElementById('checkout-modal').classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeCheckoutModal() {
  document.getElementById('checkout-modal').classList.remove('active');
  document.body.style.overflow = '';
}

function renderDeliveryAreas() {
  const areaSelect = document.getElementById('checkout-area');
  if (!areaSelect) return;
  areaSelect.innerHTML = DELIVERY_AREAS.map(area => `<option value="${area}">${area}</option>`).join('');
}

// مشاركة موقع العميل عبر GPS المتصفح
function captureCustomerLocation() {
  const statusEl = document.getElementById('gps-status');
  if (!navigator.geolocation) {
    statusEl.innerHTML = '<span style="color: #ef4444;"><i class="fas fa-times-circle"></i> تحديد الموقع غير مدعوم في متصفحك</span>';
    return;
  }

  statusEl.innerHTML = '<span style="color: var(--secondary);"><i class="fas fa-spinner fa-spin"></i> جاري تحديد إحداثيات موقعك عبر الأقمار الصناعية...</span>';

  navigator.geolocation.getCurrentPosition(
    (position) => {
      const lat = position.coords.latitude.toFixed(6);
      const lng = position.coords.longitude.toFixed(6);
      state.userLocation = {
        lat: lat,
        lng: lng,
        url: `https://maps.google.com/?q=${lat},${lng}`
      };
      statusEl.innerHTML = `
        <span style="color: #10b981; font-weight: 700;">
          <i class="fas fa-check-circle"></i> تم تحديد موقعك بدقة! 
          <a href="${state.userLocation.url}" target="_blank" style="text-decoration: underline; color: var(--primary);">عرض على الخريطة</a>
        </span>
      `;
    },
    (err) => {
      statusEl.innerHTML = `<span style="color: #ef4444;"><i class="fas fa-exclamation-triangle"></i> تعذر الحصول على الموقع: ${err.message || 'يرجى تفعيل صلاحية الـ GPS'}</span>`;
    },
    { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
  );
}

// ==========================================
// 7. إنشاء الطلب وإرسال رسالة الواتساب الرسمية
// ==========================================
async function submitOrderToWhatsApp() {
  const isAr = state.lang === 'ar';
  const name = document.getElementById('checkout-name').value.trim();
  const phone = document.getElementById('checkout-phone').value.trim();
  const area = document.getElementById('checkout-area').value;
  const address = document.getElementById('checkout-address').value.trim();
  const paymentMethod = document.querySelector('input[name="payment_method"]:checked')?.value || 'كاش عند الاستلام';
  const instructions = document.getElementById('checkout-instructions').value.trim();

  // التحقق من الحقول
  if (!name) {
    alert(isAr ? 'يرجى إدخال اسم العميل بالكامل' : 'Please enter your full name');
    document.getElementById('checkout-name').focus();
    return;
  }

  // التحقق من رقم الهاتف المصري (01xxxxxxxxx - 11 رقم)
  const phoneRegex = /^01[0125][0-9]{8}$/;
  if (!phone || !phoneRegex.test(phone)) {
    alert(isAr 
      ? 'يرجى إدخال رقم هاتف محمول مصري صحيح مكون من 11 رقماً يبدأ بـ 01' 
      : 'Please enter a valid 11-digit Egyptian mobile phone number starting with 01');
    document.getElementById('checkout-phone').focus();
    return;
  }

  if (state.orderType === 'delivery' && !address) {
    alert(isAr ? 'يرجى كتابة عنوان التوصيل بالتفصيل (الشارع، رقم العمارة، الشقة)' : 'Please enter full delivery address');
    document.getElementById('checkout-address').focus();
    return;
  }

  // الحسابات مع الخصومات
  const subtotal = state.cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
  const discount = calculateDiscount(subtotal);
  const deliveryFee = state.orderType === 'delivery' ? (state.settings.defaultDeliveryFee || 20) : 0;
  const total = Math.max(0, subtotal - discount + deliveryFee);
  const orderRef = '#ORD-' + Math.floor(100000 + Math.random() * 900000);

  // إعداد بنية كائن الطلب
  const newOrder = {
    orderRef: orderRef,
    createdAt: new Date().toISOString(),
    customerName: name,
    customerPhone: phone,
    orderType: state.orderType,
    area: area,
    address: address,
    locationUrl: state.userLocation ? state.userLocation.url : null,
    paymentMethod: paymentMethod,
    instructions: instructions,
    couponCode: state.appliedCoupon ? state.appliedCoupon.code : null,
    discount: discount,
    items: state.cart.map(i => ({
      name: i.nameAr,
      size: i.size ? i.size.nameAr : null,
      extras: i.extras ? i.extras.map(e => e.nameAr) : [],
      quantity: i.quantity,
      unitPrice: i.unitPrice,
      totalPrice: i.unitPrice * i.quantity,
      notes: i.notes
    })),
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    total: total,
    status: 'Pending' // معلق بانتظار تأكيد الإدارة
  };

  // حفظ الطلب في التخزين المحلي وفي الـ API إن كان متاحاً
  state.orders.unshift(newOrder);
  localStorage.setItem('alsheikh_orders', JSON.stringify(state.orders));

  try {
    fetch('/api/orders', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newOrder)
    }).catch(() => {});
  } catch (e) {}

  // بناء نص رسالة الواتساب بدقة عالية باللغة العربية
  const itemsText = state.cart.map((item, idx) => {
    let text = `${idx + 1}. *${item.nameAr}*`;
    if (item.size) text += `\n   - الحجم: ${item.size.nameAr}`;
    if (item.extras && item.extras.length > 0) {
      text += `\n   - إضافات: ${item.extras.map(e => e.nameAr).join(' + ')}`;
    }
    text += `\n   - الكمية: ${item.quantity}`;
    text += `\n   - السعر: ${item.unitPrice * item.quantity} ج.م`;
    if (item.notes) text += `\n   - ملاحظة: ${item.notes}`;
    return text;
  }).join('\n\n');

  let waMessage = `مرحباً مطعم *بيتزا أولاد الشيخ* 🍕\n`;
  waMessage += `أريد تأكيد الطلب التالي عبر الموقع:\n\n`;
  waMessage += `*رقم الطلب:* ${orderRef}\n`;
  waMessage += `*نوع الطلب:* ${state.orderType === 'delivery' ? 'توصيل منازل 🛵' : 'استلام من المحل 🛍️'}\n\n`;
  
  waMessage += `👤 *بيانات العميل:*\n`;
  waMessage += `- الاسم: ${name}\n`;
  waMessage += `- الهاتف: ${phone}\n`;
  
  if (state.orderType === 'delivery') {
    waMessage += `- المنطقة: ${area}\n`;
    waMessage += `- العنوان: ${address}\n`;
    if (state.userLocation) {
      waMessage += `- موقع GPS على الخريطة: ${state.userLocation.url}\n`;
    }
  }

  waMessage += `\n📋 *الطلبات:*\n${itemsText}\n\n`;

  waMessage += `💵 *الحساب الإجمالي:*\n`;
  waMessage += `- المجموع الفرعي: ${subtotal} ج.م\n`;
  if (discount > 0) {
    waMessage += `- خصم العرض / الكوبون (${state.appliedCoupon ? state.appliedCoupon.code : 'خصم خاص'}): -${discount} ج.م\n`;
  }
  if (state.orderType === 'delivery') {
    waMessage += `- رسوم التوصيل: ${deliveryFee} ج.م\n`;
  }
  waMessage += `- *الإجمالي المطلوب:* ${total} ج.م\n`;
  waMessage += `- طريقة الدفع: ${paymentMethod}\n`;

  if (instructions) {
    waMessage += `\n📝 *تعليمات إضافية:* ${instructions}\n`;
  }

  waMessage += `\n⚠️ *تنبيه:* أعلم أن هذا الطلب معلق بانتظار ردكم لتأكيد التجهيز ووقت التوصيل. شكراً لكم!`;

  // تجهيز رابط الواتساب الرسمي المباشر
  const waTargetNumber = state.settings.whatsApp || '201112962692';
  const waUrl = `https://wa.me/${waTargetNumber}?text=${encodeURIComponent(waMessage)}`;

  // إغلاق مودال الدفع ومسح السلة
  closeCheckoutModal();
  clearCart();
  state.appliedCoupon = null;

  // فتح نافذة الواتساب
  window.open(waUrl, '_blank');

  // إظهار نافذة إشعار نجاح الطلب مع التنبيه بانتظار تأكيد الإدارة
  showOrderSuccessModal(newOrder, waUrl);
}

// عرض نافذة نجاح إرسال الطلب
function showOrderSuccessModal(order, waUrl) {
  const isAr = state.lang === 'ar';
  document.getElementById('success-order-ref').textContent = order.orderRef;
  document.getElementById('success-order-total').textContent = `${order.total} ${isAr ? 'ج.م' : 'EGP'}`;
  
  const reOpenBtn = document.getElementById('success-reopen-wa');
  if (reOpenBtn) {
    reOpenBtn.onclick = () => window.open(waUrl, '_blank');
  }

  document.getElementById('order-success-modal').classList.add('active');
  document.body.style.overflow = 'hidden';
}

function closeOrderSuccessModal() {
  document.getElementById('order-success-modal').classList.remove('active');
  document.body.style.overflow = '';
}

// ==========================================
// 8. لوحة تحكم الإدارة (Admin Dashboard)
// ==========================================
function openAdminModal() {
  window.location.href = 'admin.html';
}

function closeAdminModal() {
  document.getElementById('admin-modal').classList.remove('active');
  document.body.style.overflow = '';
}

function showAdminLogin() {
  document.getElementById('admin-login-view').style.display = 'block';
  document.getElementById('admin-dashboard-view').style.display = 'none';
}

function showAdminDashboard() {
  document.getElementById('admin-login-view').style.display = 'none';
  document.getElementById('admin-dashboard-view').style.display = 'block';
  renderAdminProductsTab();
  renderAdminOrdersTab();
  renderAdminSettingsTab();
}

function handleAdminLogin(e) {
  e.preventDefault();
  const user = document.getElementById('admin-username').value.trim();
  const pass = document.getElementById('admin-password').value.trim();

  // اسم المستخدم وكلمة المرور الافتراضية
  if (user === 'admin' && pass === 'AdminPassword123!') {
    state.isAdminLoggedIn = true;
    sessionStorage.setItem('alsheikh_admin_auth', 'true');
    showAdminDashboard();
  } else {
    alert('اسم المستخدم أو كلمة المرور غير صحيحة. الافتراضي: admin / AdminPassword123!');
  }
}

function handleAdminLogout() {
  state.isAdminLoggedIn = false;
  sessionStorage.removeItem('alsheikh_admin_auth');
  showAdminLogin();
}

function switchAdminTab(tabName) {
  document.querySelectorAll('.admin-tab-btn').forEach(btn => {
    btn.classList.toggle('active', btn.dataset.tab === tabName);
  });
  document.querySelectorAll('.admin-tab-pane').forEach(pane => {
    const isTarget = pane.id === `tab-${tabName}`;
    pane.classList.toggle('active', isTarget);
    pane.style.display = isTarget ? 'block' : 'none';
  });
}

// تبويب المنتجات في لوحة الإدارة
function renderAdminProductsTab() {
  const container = document.getElementById('admin-products-table-body');
  if (!container) return;

  container.innerHTML = state.products.map(prod => `
    <tr>
      <td style="padding: 10px; border-bottom: 1px solid var(--border-color);">
        <img src="${prod.imageUrl}" style="width: 40px; height: 40px; border-radius: 6px; object-fit: cover;">
      </td>
      <td style="padding: 10px; border-bottom: 1px solid var(--border-color); font-weight: 700;">
        ${prod.nameAr}
        <div style="font-size: 11px; color: var(--text-muted);">${prod.nameEn}</div>
      </td>
      <td style="padding: 10px; border-bottom: 1px solid var(--border-color);">
        <input type="number" value="${prod.basePrice}" style="width: 75px; padding: 4px;" onchange="updateProductPrice('${prod.id}', this.value)"> ج.م
      </td>
      <td style="padding: 10px; border-bottom: 1px solid var(--border-color);">
        <button class="btn-sm" style="background: ${prod.isSample ? '#f59e0b' : '#10b981'}; color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px;" onclick="toggleProductSample('${prod.id}')">
          ${prod.isSample ? 'عينة تجريبية' : 'معتمد رسمي'}
        </button>
      </td>
      <td style="padding: 10px; border-bottom: 1px solid var(--border-color);">
        <button class="btn-sm" style="background: ${prod.isAvailable ? '#10b981' : '#ef4444'}; color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px;" onclick="toggleProductAvailability('${prod.id}')">
          ${prod.isAvailable ? 'متاح للطلب' : 'غير متوفر حالياً'}
        </button>
      </td>
    </tr>
  `).join('');
}

function updateProductPrice(prodId, newPrice) {
  const p = state.products.find(item => item.id === prodId);
  if (p) {
    p.basePrice = parseFloat(newPrice) || p.basePrice;
    localStorage.setItem('alsheikh_products', JSON.stringify(state.products));
    renderProducts();
  }
}

function toggleProductSample(prodId) {
  const p = state.products.find(item => item.id === prodId);
  if (p) {
    p.isSample = !p.isSample;
    localStorage.setItem('alsheikh_products', JSON.stringify(state.products));
    renderAdminProductsTab();
    renderProducts();
  }
}

function toggleProductAvailability(prodId) {
  const p = state.products.find(item => item.id === prodId);
  if (p) {
    p.isAvailable = !p.isAvailable;
    localStorage.setItem('alsheikh_products', JSON.stringify(state.products));
    renderAdminProductsTab();
    renderProducts();
  }
}

// تبويب الطلبات في لوحة الإدارة
function renderAdminOrdersTab() {
  const container = document.getElementById('admin-orders-list');
  if (!container) return;

  if (state.orders.length === 0) {
    container.innerHTML = '<div style="padding: 30px; text-align: center; color: var(--text-muted);">لا توجد طلبات مسجلة بعد.</div>';
    return;
  }

  container.innerHTML = state.orders.map(order => `
    <div style="background-color: var(--bg-card-alt); border-radius: var(--radius-sm); border: 1px solid var(--border-color); padding: 14px; margin-bottom: 12px;">
      <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); padding-bottom: 8px; margin-bottom: 8px;">
        <strong>${order.orderRef} - ${order.customerName} (${order.customerPhone})</strong>
        <span style="font-size: 12px; color: var(--text-muted);">${new Date(order.createdAt).toLocaleTimeString('ar-EG')}</span>
      </div>
      <div style="font-size: 13px; margin-bottom: 6px;">
        <span>النوع: <strong>${order.orderType === 'delivery' ? 'توصيل' : 'استلام'}</strong></span> | 
        <span>الإجمالي: <strong style="color: var(--primary);">${order.total} ج.م</strong></span>
      </div>
      <div style="font-size: 12.5px; color: var(--text-muted); margin-bottom: 10px;">
        ${order.items.map(i => `${i.name} (x${i.quantity})`).join(', ')}
      </div>
      <div style="display: flex; align-items: center; gap: 8px;">
        <span style="font-size: 12px;">تحديث الحالة:</span>
        <select onchange="updateOrderStatus('${order.orderRef}', this.value)" style="padding: 4px 8px; font-size: 12px;">
          <option value="Pending" ${order.status === 'Pending' ? 'selected' : ''}>قيد المراجعة</option>
          <option value="Confirmed" ${order.status === 'Confirmed' ? 'selected' : ''}>تم التأكيد</option>
          <option value="Preparing" ${order.status === 'Preparing' ? 'selected' : ''}>قيد التجهيز</option>
          <option value="OutForDelivery" ${order.status === 'OutForDelivery' ? 'selected' : ''}>في الطريق للعميل</option>
          <option value="Delivered" ${order.status === 'Delivered' ? 'selected' : ''}>تم التسليم</option>
          <option value="Cancelled" ${order.status === 'Cancelled' ? 'selected' : ''}>ملغي</option>
        </select>
        ${order.locationUrl ? `<a href="${order.locationUrl}" target="_blank" style="font-size: 12px; color: var(--primary); text-decoration: underline;"><i class="fas fa-map-marker-alt"></i> موقع العميل</a>` : ''}
      </div>
    </div>
  `).join('');
}

function updateOrderStatus(orderRef, newStatus) {
  const o = state.orders.find(item => item.orderRef === orderRef);
  if (o) {
    o.status = newStatus;
    localStorage.setItem('alsheikh_orders', JSON.stringify(state.orders));
    renderAdminOrdersTab();
  }
}

// تبويب إعدادات المطعم في لوحة الإدارة
function renderAdminSettingsTab() {
  document.getElementById('setting-phone').value = state.settings.phone || '';
  document.getElementById('setting-whatsapp').value = state.settings.whatsApp || '';
  document.getElementById('setting-address').value = state.settings.addressAr || '';
  document.getElementById('setting-delivery-fee').value = state.settings.defaultDeliveryFee || 20;
  document.getElementById('setting-announcement').value = state.settings.announcementAr || '';
}

function saveAdminSettings(e) {
  e.preventDefault();
  state.settings.phone = document.getElementById('setting-phone').value.trim();
  state.settings.whatsApp = document.getElementById('setting-whatsapp').value.trim();
  state.settings.addressAr = document.getElementById('setting-address').value.trim();
  state.settings.defaultDeliveryFee = parseFloat(document.getElementById('setting-delivery-fee').value) || 20;
  state.settings.announcementAr = document.getElementById('setting-announcement').value.trim();

  localStorage.setItem('alsheikh_settings', JSON.stringify(state.settings));
  updateStaticTexts();
  updateCartUI();
  alert('تم حفظ إعدادات المطعم بنجاح!');
}

// ==========================================
// 9. ربط الأحداث (Event Listeners)
// ==========================================
function setupEventListeners() {
  // زر تبديل الوضع الليلي واللغة
  document.getElementById('theme-toggle-btn')?.addEventListener('click', toggleTheme);
  document.getElementById('lang-toggle-btn')?.addEventListener('click', toggleLanguage);

  // شريط البحث
  document.getElementById('search-input')?.addEventListener('input', (e) => {
    handleSearch(e.target.value);
  });

  // أزرار السلة
  document.getElementById('cart-nav-btn')?.addEventListener('click', openCartDrawer);
  document.getElementById('close-cart-btn')?.addEventListener('click', closeCartDrawer);
  document.getElementById('drawer-backdrop')?.addEventListener('click', closeCartDrawer);

  // إغلاق المودالات عند الضغط على الخلفية
  document.querySelectorAll('.modal-backdrop').forEach(modal => {
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        modal.classList.remove('active');
        document.body.style.overflow = '';
      }
    });
  });
}
