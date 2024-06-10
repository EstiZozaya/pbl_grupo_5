document.addEventListener('DOMContentLoaded', function () {
    const loginForm = document.getElementById('login-form');

    loginForm.addEventListener('submit', function (event) {
        event.preventDefault();

        const username = document.getElementById('username').value;
        const password = document.getElementById('password').value;

        // Lógica básica de verificación de usuario y contraseña
        if (username === 'izaro.aragunde' && password === '1234') {
            // Si las credenciales son válidas, establece la sesión y redirige a la página principal
            localStorage.setItem('isAuthenticated', 'true');
            window.location.href = 'Areacliente.html';
        } else {
            // Si las credenciales son inválidas, muestra un mensaje de error
            alert('Usuario o contraseña incorrectos. Por favor, inténtalo de nuevo.');
        }
    });
});

document.getElementById("loginForm").addEventListener("submit", function(event) {
            event.preventDefault(); // Evita que el formulario se envíe por defecto
            // Aquí puedes agregar la lógica para validar las credenciales del usuario
            // Por simplicidad, supongamos que las credenciales son válidas y redireccionamos a dashboard.html
            window.location.href = "Areacliente.html";
        });