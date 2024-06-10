document.addEventListener("DOMContentLoaded", function() {
    var xhr = new XMLHttpRequest();
    xhr.open("GET", "PBL_Talde5.xml", true);
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            var xml = xhr.responseXML;
            var datosDiv = document.getElementById("datos");

            if (!datosDiv) {
                console.error("El elemento con id 'datos' no se encontró en el DOM.");
                return;
            }

            var table = document.createElement("table");
            var thead = document.createElement("thead");
            var tbody = document.createElement("tbody");

            // Crear encabezado de la tabla
            var headerRow = document.createElement("tr");
            var headers = ["ID", "Sexo", "Hospital", "Teléfono", "Historial Médico", "Diagnóstico de Glaucoma", "Fecha de Diagnóstico", "Imagen"];
            headers.forEach(function(header) {
                var th = document.createElement("th");
                th.textContent = header;
                headerRow.appendChild(th);
            });
            thead.appendChild(headerRow);

            // Crear cuerpo de la tabla
            var pacientes = xml.getElementsByTagName("Paciente");
            for (var i = 0; i < pacientes.length; i++) {
                var paciente = pacientes[i];
                var row = document.createElement("tr");

                // Extraer datos del paciente
                var id = paciente.getAttribute("id");
                var sexo = paciente.getElementsByTagName("Sexo")[0].textContent;
                var hospital = paciente.getElementsByTagName("Hospital")[0].textContent;
                var telefono = paciente.getElementsByTagName("Telefono")[0].textContent;

                var historialMedico = paciente.getElementsByTagName("HistorialMedico")[0];
                var historial = "";
                var entradas = historialMedico.getElementsByTagName("Entrada");
                for (var j = 0; j < entradas.length; j++) {
                    var entrada = entradas[j];
                    var fecha = entrada.getElementsByTagName("Fecha")[0].textContent;
                    var descripcion = entrada.getElementsByTagName("Descripcion")[0].textContent;
                    historial += `<b>Fecha:</b> ${fecha}<br><b>Descripción:</b> ${descripcion}<br>`;

                    // Agregar información de tratamiento
                    var tratamiento = entrada.getElementsByTagName("Tratamiento")[0];
                    if (tratamiento) {
                        var medicacion = tratamiento.getElementsByTagName("Medicacion")[0];
                        if (medicacion) {
                            var nombreMed = medicacion.getElementsByTagName("NombreMed")[0].textContent;
                            var dosis = medicacion.getElementsByTagName("Dosis")[0].textContent;
                            var frecuencia = medicacion.getElementsByTagName("Frecuencia")[0].textContent;
                            historial += `<b>Medicación:</b> ${nombreMed}, ${dosis}, ${frecuencia}<br>`;
                        }
                        var procedimiento = tratamiento.getElementsByTagName("Procedimiento")[0];
                        if (procedimiento) {
                            var tipo = procedimiento.getElementsByTagName("Tipo")[0].textContent;
                            historial += `<b>Procedimiento:</b> ${tipo}<br>`;
                        }
                    }
                    historial += "<br>";  // Añadir un espacio entre entradas
                }

                var glaucoma = paciente.getElementsByTagName("Glaucoma")[0];
                var diagnostico = glaucoma.getElementsByTagName("Diagnostico")[0];
                var resultado = diagnostico.getElementsByTagName("Resultado")[0].textContent;
                var fechaDiagnostico = diagnostico.getElementsByTagName("FechaDiagnostico")[0].textContent;
                var imagen = diagnostico.getElementsByTagName("Imagen")[0].textContent;
                var diagnosticoCompleto = `Resultado: ${resultado}`;

                // Crear celdas de la fila
                var idCell = document.createElement("td");
                idCell.innerHTML = id;
                var sexoCell = document.createElement("td");
                sexoCell.innerHTML = sexo;
                var hospitalCell = document.createElement("td");
                hospitalCell.innerHTML = hospital;
                var telefonoCell = document.createElement("td");
                telefonoCell.innerHTML = telefono;
                var historialCell = document.createElement("td");
                historialCell.innerHTML = historial;
                historialCell.style.minWidth = "200px"; // Ancho mínimo ajustado
                var diagnosticoCell = document.createElement("td");
                diagnosticoCell.innerHTML = diagnosticoCompleto;
                var fechaDiagnosticoCell = document.createElement("td");
                fechaDiagnosticoCell.innerHTML = fechaDiagnostico;
                var imagenCell = document.createElement("td");
                var imagenElement = document.createElement("img");
                imagenElement.src = imagen;
                imagenElement.alt = "Imagen de diagnóstico de glaucoma";
                imagenCell.appendChild(imagenElement);

                // Añadir celdas a la fila
                row.appendChild(idCell);
                row.appendChild(sexoCell);
                row.appendChild(hospitalCell);
                row.appendChild(telefonoCell);
                row.appendChild(historialCell);
                row.appendChild(diagnosticoCell);
                row.appendChild(fechaDiagnosticoCell);
                row.appendChild(imagenCell);

                // Añadir fila al cuerpo de la tabla
                tbody.appendChild(row);
            }

            table.appendChild(thead);
            table.appendChild(tbody);
            datosDiv.appendChild(table);
        }
    };
    xhr.send();
});





