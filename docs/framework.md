# Elección del framework CSS · Geo Adopt

## 1. Comparativa

| Opción | Cómo funciona | A favor | En contra |
|---|---|---|---|
| Bootstrap | Componentes ya hechos que se usan con clases (`btn`, `card`, `form-control`) | Muy rápido para empezar. Mucha documentación. | Todas las webs se parecen. Personalizar colores y tamaños para que coincidan con Figma obliga a sobrescribir estilos. |
| **Tailwind CSS** | Clases pequeñas que se combinan (`bg-primario`, `px-4`, `rounded`) y que se configuran con los colores y tipografías propios | Fiel al diseño de Figma: los colores y fuentes de la guía de estilo se definen una vez y se usan en todo el proyecto. Encaja con los componentes reutilizables de React. Ya está en el stack de la primera entrega. | Más clases en el HTML. Hay que aprender los nombres de las clases. |
| CSS propio | Hojas de estilo escritas a mano | Control total. | Más lento, más código que mantener y más riesgo de que cada miembro escriba los estilos de forma distinta. |

## 2. Decisión: Tailwind CSS

Elegimos **Tailwind CSS** por estos motivos:

1. **Fidelidad a la guía de estilo de Figma.** Los colores, tipografías y espacios de Figma se configuran como variables del proyecto, así que no hay que sobrescribir estilos de un framework ajeno.
2. **Componentes reutilizables.** Con React, un botón o una tarjeta se escribe una vez con sus clases y se reutiliza en toda la app en lugar de copiar y pegar.
3. **Identidad propia.** A diferencia de Bootstrap, la app no se parece a otras webs que usan los componentes por defecto.
4. **Ya estaba previsto.** La tabla 5.1 de la primera entrega indica React + Tailwind CSS para el frontend, por lo que no cambia el stack.
5. **Rapidez.** Permite maquetar sin salir del componente y sin escribir hojas de estilo a mano.

## 3. Configuración con la guía de estilo

Tailwind está instalado en `frontend/` y los valores de la guía de estilo están definidos en `frontend/src/index.css`, dentro del bloque `@theme`.

| Elemento | Nombre en Tailwind | Valor |
|---|---|---|
| Color principal (rosa) | `primario` | `#E91E63` |
| Color de texto y títulos | `oscuro` | `#404040` |
| Color secundario (gris) | `gris` | `#9E9E9E` |
| Color de fondo | `fondo` | `#FFFFFF` |
| Tipografía de títulos | `font-titulo` | Oswald |
| Tipografía de texto | `font-texto` | Fira Mono |

Ejemplo de uso:

```jsx
<button className="bg-primario text-white font-titulo px-4 py-2 rounded">
  Reportar animal
</button>
```
