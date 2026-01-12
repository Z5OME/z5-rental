let currentData = {};
let selectedPayment = 'cash';

window.addEventListener('message', function (event) {
    const data = event.data;

    if (data.action === 'openMenu') {
        openMenu(data);
    } else if (data.action === 'openInput') {
        openInput(data);
    } else if (data.action === 'close') {
        closeAll();
    }
});

function applyTranslations(t) {
    if (!t) return;

    const set = (id, text) => {
        const el = document.getElementById(id);
        if (el) el.textContent = text;
    };

    set('menu-title', t.menu_title);
    set('menu-footer-text', t.menu_footer_text);
    set('input-title', t.input_header);
    set('label-duration', t.input_duration_label);

    const input = document.getElementById('rental-hours');
    if (input) input.placeholder = t.input_input_placeholder;

    set('label-suffix-hrs', t.input_suffix_hrs);
    set('label-price-per-hour', t.input_price_per_hour_label);
    set('label-total-amount', t.input_total_amount_label);
    set('label-payment-method', t.input_payment_label);
    set('label-cash', t.input_cash);
    set('label-bank', t.input_bank);
    set('btn-cancel', t.input_cancel_btn);
    set('btn-confirm', t.input_confirm_btn);
}

document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
        closeAll();
    }
});

function openMenu(data) {
    currentData = data;
    document.getElementById('rental-container').classList.remove('hidden');
    document.getElementById('vehicle-menu').classList.remove('hidden');
    document.getElementById('input-dialog').classList.add('hidden');

    if (data.translations) applyTranslations(data.translations);

    document.getElementById('menu-title').textContent = data.translations ? data.translations.menu_title : (data.title || 'Vehicle Rental');

    const vehicleList = document.getElementById('vehicle-list');
    vehicleList.innerHTML = '';

    data.vehicles.forEach((vehicle, index) => {
        const item = document.createElement('div');
        item.className = 'vehicle-item';
        item.innerHTML = `
            <div class="vehicle-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.5 2.8C1.4 11.3 1 12.1 1 13v3c0 .6.4 1 1 1h2"/>
                    <circle cx="7" cy="17" r="2"/>
                    <circle cx="17" cy="17" r="2"/>
                </svg>
            </div>
            <div class="vehicle-info">
                <div class="vehicle-name">${vehicle.name}</div>
                <div class="vehicle-price">${data.priceFormat.replace('%s', vehicle.price)}</div>
            </div>
            <div class="vehicle-arrow">›</div>
        `;
        item.onclick = () => selectVehicle(vehicle);
        vehicleList.appendChild(item);
    });
}

function selectVehicle(vehicle) {
    document.getElementById('vehicle-menu').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/selectVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            model: vehicle.model,
            price: vehicle.price,
            spawnPoints: currentData.spawnPoints
        })
    });
}

function openInput(data) {
    currentData = data;
    document.getElementById('rental-container').classList.remove('hidden');
    document.getElementById('vehicle-menu').classList.add('hidden');
    document.getElementById('input-dialog').classList.remove('hidden');

    if (data.translations) applyTranslations(data.translations);

    document.getElementById('input-title').textContent = data.translations ? data.translations.input_header : (data.title || 'Rental Duration');
    document.getElementById('price-per-hour').textContent = '$' + data.price;
    document.getElementById('rental-hours').value = 1;

    selectedPayment = 'cash';
    updatePaymentSelection();
    updateTotal();

    document.getElementById('rental-hours').addEventListener('input', updateTotal);
}

function updatePaymentSelection() {
    document.querySelectorAll('.payment-option').forEach(opt => {
        opt.classList.remove('selected');
        if (opt.dataset.value === selectedPayment) {
            opt.classList.add('selected');
        }
    });
}

document.querySelectorAll('.payment-option').forEach(option => {
    option.addEventListener('click', function () {
        selectedPayment = this.dataset.value;
        updatePaymentSelection();
    });
});

function adjustHours(delta) {
    const input = document.getElementById('rental-hours');
    let val = parseInt(input.value) || 0;
    val += delta;
    if (val < 1) val = 1;
    input.value = val;
    updateTotal();
}

function updateTotal() {
    const hours = parseInt(document.getElementById('rental-hours').value) || 1;
    const total = hours * currentData.price;
    document.getElementById('total-price').textContent = '$' + total;
}

function confirmRental() {
    const hours = parseInt(document.getElementById('rental-hours').value) || 1;

    if (hours < 1) {
        return;
    }

    fetch(`https://${GetParentResourceName()}/confirmRental`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            hours: hours,
            paymentType: selectedPayment,
            model: currentData.model,
            price: currentData.price,
            spawnPoints: currentData.spawnPoints
        })
    });
    closeAll();
}

function closeMenu() {
    document.getElementById('vehicle-menu').classList.add('hidden');
    document.getElementById('rental-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function closeInput() {
    document.getElementById('input-dialog').classList.add('hidden');
    document.getElementById('rental-container').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function closeAll() {
    document.getElementById('rental-container').classList.add('hidden');
    document.getElementById('vehicle-menu').classList.add('hidden');
    document.getElementById('input-dialog').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}
