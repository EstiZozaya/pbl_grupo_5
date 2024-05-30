<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <html lang="es">
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>ÁREA DE CLIENTES</title>
                <link rel="stylesheet" href="Areacliente.css"/>
                <style>
                    table {
                        width: 90%;
                        border-collapse: collapse;
                    }
                    th, td {
                        border: 1px solid black;
                        padding: 8px;
                        text-align: center;
                    }
                    th {
                        background-color: #f2f2f2;
                    }
                </style>
            </head>
            <body>
                <header>
                    <a href="Principal.html" class="logo">
                        <img src="ImagenesPBL/Logo2.png" alt="Logo" class="logo-img"/>
                    </a>
                    <nav class="navbar">
                        <ul>
                            <li><a href="Principal.html" class="active">Inicio</a></li>
                            <li><a href="Sobrenosotros.html">Quiénes somos</a></li>
                            <li><a href="Producto.html">Productos</a></li>
                            <li><a href="Inicio.html">Área cliente</a></li>
                            <li><a href="Contacto.html">Contacto</a></li>
                            <li><a href="Preguntas.html">FAQ</a></li>
                        </ul>
                    </nav>
                    <div class="fas fa-bars"></div>
                </header>

                <main>
                    <h1>Datos desde XML</h1>
                    <div id="datos">
                        <h1>En la siguiente lista se muestran los datos de los pacientes, incluyendo el diagnóstico y la imagen utilizada para ello</h1>
                        <table>
                            <tr>
                                <th>ID</th>
                                <th>Sexo</th>
                                <th>Hospital</th>
                                <th>Teléfono</th>
                                <th>Historial Médico</th>
                                <th>Fecha de Diagnóstico</th>
                                <th>Glaucoma</th>
                                <th>Imagen</th>
                            </tr>
                            <xsl:for-each select="Analisis_Software/Paciente">
                                <tr>
                                    <td><xsl:value-of select="@id"/></td>
                                    <td><xsl:value-of select="Sexo"/></td>
                                    <td><xsl:value-of select="Hospital"/></td>
                                    <td><xsl:value-of select="Telefono"/></td>
                                    <td>
                                        <xsl:for-each select="HistorialMedico/Entrada">
                                            <div>
                                                <strong>Fecha:</strong> <xsl:value-of select="Fecha"/><br/>
                                                <strong>Descripción:</strong> <xsl:value-of select="Descripcion"/><br/>
                                                <xsl:choose>
                                                    <xsl:when test="Tratamiento/Medicacion">
                                                        <strong>Medicación:</strong><br/>
                                                        <strong>Nombre:</strong> <xsl:value-of select="Tratamiento/Medicacion/NombreMed"/><br/>
                                                        <strong>Dosis:</strong> <xsl:value-of select="Tratamiento/Medicacion/Dosis"/><br/>
                                                        <strong>Frecuencia:</strong> <xsl:value-of select="Tratamiento/Medicacion/Frecuencia"/><br/>
                                                    </xsl:when>
                                                    <xsl:when test="Tratamiento/Procedimiento">
                                                        <strong>Procedimiento:</strong><br/>
                                                        <strong>Tipo:</strong> <xsl:value-of select="Tratamiento/Procedimiento/Tipo"/><br/>
                                                    </xsl:when>
                                                </xsl:choose>
                                                <hr/>
                                            </div>
                                        </xsl:for-each>
                                    </td>
                                    <td><xsl:value-of select="Glaucoma/Diagnostico/FechaDiagnostico"/></td>
                                    <td><xsl:value-of select="Glaucoma/Diagnostico/Resultado"/></td>
                                    <td>
                                        <xsl:if test="Glaucoma/Diagnostico/Imagen">
                                            <img src="{Glaucoma/Diagnostico/Imagen}" alt="Foto de Paciente" style="max-width: 200px;"/>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </div>
                </main>

                <section class="footer">
                    <div class="contact-location-container">
                        <div class="contact">
                            <h2>Contacto</h2>
                            <ul>
                                <li>Teléfono: <a href="tel:+123456789">+34648951789</a></li>
                                <li>Email: <a href="mailto:info@tusitioweb.com">info@eyehealthdiagnostics.com</a></li>
                            </ul>
                        </div>
                        <div class="location">
                            <h2>Ubicación</h2>
                            <address>
                                <br>Dirección: Loramendi kalea, 4, Mondragón, España</br>
                                <img src="ImagenesPBL/Mapa.png" class="image" width="400" height="200"/>
                            </address>
                        </div>
                    </div>
                    <p class="footer-text"> @copy; 2024 EyeHealth Diagnostics. Todos los derechos reservados.</p>
                </section>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>

