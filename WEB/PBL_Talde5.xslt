<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="yes" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>Análisis de Software - Pacientes</title>
                <style>
                    table {
                        width: 100%;
                        border-collapse: collapse;
                    }
                    th, td {
                        border: 1px solid black;
                        padding: 8px;
                        text-align: left;
                    }
                    th {
                        background-color: #f2f2f2;
                    }
                </style>
            </head>
            <body>
                <h1>Lista de Pacientes</h1>
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
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
