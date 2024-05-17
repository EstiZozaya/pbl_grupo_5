document.addEventListener('DOMContentLoaded', function () {
    const tabs = document.querySelectorAll('.tab');

    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.parentElement.classList.remove('active'));
            tab.parentElement.classList.add('active');
        });
    });
});

document.addEventListener('DOMContentLoaded', function () {
    const logoutButton = document.getElementById('logout-button');
    logoutButton.addEventListener('click', function () {
        // Elimina la información de autenticación del almacenamiento local
        localStorage.removeItem('isAuthenticated');
        // Redirige al usuario a la página de inicio de sesión
        window.location.href = 'Inicio.html';
    });
});

document.addEventListener('DOMContentLoaded', function() {
    // Obtener el botón y el contenedor de información adicional
    const botonDesplegable = document.getElementById('boton-desplegable');
    const informacionAdicional = document.getElementById('informacion-adicional');

    // Agregar un evento de clic al botón
    botonDesplegable.addEventListener('click', function() {
        // Alternar la visibilidad de la información adicional
        if (informacionAdicional.style.display === 'none') {
            informacionAdicional.style.display = 'block';
        } else {
            informacionAdicional.style.display = 'none';
        }
    });
});