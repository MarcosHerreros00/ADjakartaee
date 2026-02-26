// Determinar la URL de la API de forma más robusta
const getBaseUrl = () => {
    const path = window.location.pathname;
    // Si estamos en un subdirectorio como /contactos/, retrocedemos un nivel
    if (path.includes('/contactos/')) {
        return path.split('/contactos/')[0] + '/api/vuelos';
    }
    // Si estamos en la raíz o en otro lugar, asumimos /api/vuelos relativo a la raíz del contexto
    // Buscamos el primer segmento del path (context root)
    const segments = path.split('/').filter(s => s.length > 0);
    if (segments.length > 1) {
        return '/' + segments[0] + '/api/vuelos';
    }
    return '/api/vuelos';
};

const API_URL = getBaseUrl();
console.log('Intentando conectar con la API en:', API_URL);

document.addEventListener('DOMContentLoaded', () => {
    const tablaBody = document.getElementById('tabla-vuelos');

    cargarVuelos();

    async function cargarVuelos() {
        try {
            console.log('Cargando vuelos desde:', API_URL);
            const respuesta = await fetch(API_URL);

            console.log('Estado de la respuesta:', respuesta.status, respuesta.statusText);

            if (!respuesta.ok) {
                const errorText = await respuesta.text();
                console.error('Error de servidor:', errorText);
                throw new Error(`Error ${respuesta.status}: ${respuesta.statusText}`);
            }

            const vuelos = await respuesta.json();
            console.log('Vuelos recibidos:', vuelos);
            pintarTabla(vuelos);
        } catch (error) {
            console.error('Error al realizar fetch:', error);
            tablaBody.innerHTML = `<tr><td colspan="9" class="no-data">
                Error al cargar los vuelos: ${error.message}<br>
                <small>Verifica la consola del navegador (F12) para más detalles.</small>
            </td></tr>`;
        }
    }

    function pintarTabla(vuelos) {
        tablaBody.innerHTML = '';

        if (!vuelos || vuelos.length === 0) {
            console.log('La lista de vuelos está vacía.');
            tablaBody.innerHTML = '<tr><td colspan="9" class="no-data">No hay vuelos registrados en la base de datos.</td></tr>';
            return;
        }

        vuelos.forEach(vuelo => {
            const tr = document.createElement('tr');

            tr.innerHTML = `
                <td><strong>${vuelo.numeroVuelo || 'N/A'}</strong></td>
                <td>${vuelo.origen || 'N/A'}</td>
                <td>${vuelo.destino || 'N/A'}</td>
                <td>${vuelo.aerolinea || 'N/A'}</td>
                <td>${vuelo.avion || 'N/A'}</td>
                <td>${vuelo.terminal || 'N/A'}</td>
                <td>${vuelo.puerta || 'N/A'}</td>
                <td>${formatDate(vuelo.horaSalida)}</td>
                <td>${formatDate(vuelo.horaLlegada)}</td>
            `;

            tablaBody.appendChild(tr);
        });
    }

    function formatDate(dateValue) {
        if (!dateValue) return '-';

        try {
            // Manejar si dateValue es un array [YYYY, MM, DD, HH, mm] que a veces JSON-B produce
            if (Array.isArray(dateValue)) {
                return `${dateValue[2]}/${dateValue[1]}/${dateValue[0]} ${dateValue[3]}:${dateValue[4].toString().padStart(2, '0')}`;
            }

            const date = new Date(dateValue);
            if (isNaN(date.getTime())) return dateValue; // Si no es fecha válida, mostrar original

            return date.toLocaleString('es-ES', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
        } catch (e) {
            console.error('Error formateando fecha:', e);
            return dateValue;
        }
    }
});
