
-- ---------- TABLAS ----------
CREATE TABLE categorias (
    id_categoria INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(50) NOT NULL
);
 
CREATE TABLE productos (
    id_producto  INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    precio       NUMERIC(10,2) NOT NULL,
    id_categoria INT NOT NULL REFERENCES categorias(id_categoria)
);
 
CREATE TABLE clientes (
    id_cliente     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    email          VARCHAR(100) NOT NULL,
    fecha_registro DATE NOT NULL
);
 
CREATE TABLE ventas (
    id_venta    INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente  INT NOT NULL REFERENCES clientes(id_cliente),
    id_producto INT NOT NULL REFERENCES productos(id_producto),
    cantidad    INT NOT NULL,
    fecha_venta DATE NOT NULL
);
 
-- ---------- DATOS ----------
INSERT INTO categorias (nombre) VALUES
    ('Electrónica'),
    ('Hogar'),
    ('Indumentaria'),
    ('Deportes'),
    ('Libros'),
    ('Juguetes');
 
INSERT INTO productos (nombre, precio, id_categoria) VALUES
    ('Auriculares Bluetooth',  25000.00, 1),
    ('Smartwatch',             60000.00, 1),
    ('Lámpara LED',             8000.00, 2),
    ('Set de sábanas',         18000.00, 2),
    ('Remera deportiva',       12000.00, 3),
    ('Campera de abrigo',      45000.00, 3),
    ('Pelota de fútbol',       15000.00, 4),
    ('Bicicleta fija',        120000.00, 4),
    ('Novela Rayuela',          9000.00, 5),
    ('Rompecabezas 1000 pzs',   7000.00, 6);
 
INSERT INTO clientes (nombre, email, fecha_registro) VALUES
    ('Lucía Fernández',   'lucia@mail.com',    '2025-11-02'),
    ('Martín Gómez',      'martin@mail.com',   '2025-11-15'),
    ('Sofía Ramírez',     'sofia@mail.com',    '2025-12-01'),
    ('Diego Torres',      'diego@mail.com',    '2025-12-10'),
    ('Valentina Díaz',    'valen@mail.com',    '2026-01-05'),
    ('Carlos Medina',     'carlos@mail.com',   '2026-01-20'),
    ('Camila Ruiz',       'camila@mail.com',   '2026-02-14'),
    ('Joaquín Herrera',   'joaquin@mail.com',  '2026-03-03');
 
INSERT INTO ventas (id_cliente, id_producto, cantidad, fecha_venta) VALUES
    (1, 1,  2, '2026-01-10'),
    (1, 1,  1, '2026-02-15'),
    (1, 3,  3, '2026-03-05'),
    (2, 2,  1, '2026-01-20'),
    (2, 7,  2, '2026-02-28'),
    (2, 7,  1, '2026-04-02'),
    (3, 5,  3, '2026-03-12'),
    (3, 9,  1, '2026-03-30'),
    (4, 8,  1, '2026-02-05'),
    (4, 4,  2, '2026-04-18'),
    (4, 4,  1, '2026-05-09'),
    (5, 6,  1, '2026-01-25'),
    (5, 1,  1, '2026-05-20'),
    (6, 9,  2, '2026-04-22'),
    (6, 10, 1, '2026-05-11');
 
-- ---------- VERIFICACIÓN RÁPIDA ----------
SELECT 'categorias' AS tabla, COUNT(*) AS filas FROM categorias
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'clientes',  COUNT(*) FROM clientes
UNION ALL SELECT 'ventas',    COUNT(*) FROM ventas;
 
/*Rentabilidad por categoría: Se necesita identificar las categorias que mas ingresos totales generaron
para toma de decisiones, se excluye las categorias con menos de 50 unidades vendidas
ya que no son representativas para el analisis*/
SELECT
    c.nombre AS categoria,
    SUM(v.cantidad)  AS unidades_vendidas,
    SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas v
JOIN productos p ON p.id_producto = v.id_producto
JOIN categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.nombre
HAVING SUM(v.cantidad) >= 50
ORDER BY ingreso_total DESC;

/*Clientes sin compras: Es necesario identificar los clientes cargados en sistema que
todavia no realizaron ninguna compra. */

SELECT
	c.nombre,
	c.email
FROM clientes c
LEFT JOIN ventas v ON v.id_cliente = c.id_cliente
WHERE v.id_venta IS NULL;

/*Top de compras por cliente: que producto fue mas veces comprado por cada cliente (COUNT) 
y la ultima fecha que compro. */
SELECT
    c.nombre AS cliente,
    p.nombre AS producto,
    COUNT(*) AS veces_comprado,
    (SELECT MAX(v3.fecha_venta)
     FROM ventas v3
     WHERE v3.id_cliente = c.id_cliente) AS ultima_transaccion
FROM clientes c
JOIN ventas v ON v.id_cliente = c.id_cliente
JOIN productos p ON p.id_producto = v.id_producto
GROUP BY c.id_cliente, c.nombre, p.id_producto, p.nombre
HAVING COUNT(*) >= ALL (
    SELECT COUNT(*)
    FROM ventas v2
    WHERE v2.id_cliente = c.id_cliente
    GROUP BY v2.id_producto
)
ORDER BY c.nombre, p.nombre;
	