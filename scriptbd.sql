-- ==================== TABLAS ====================

CREATE TABLE banco (
    id_banco integer NOT NULL,
    nombre character varying(100)
);
ALTER TABLE banco OWNER TO postgres;

CREATE TABLE cajero_automatico (
    id_cajero_automatico integer NOT NULL,
    ubicacion character varying(100),
    id_banco integer,
    estado character varying(20),
    monto_cajero numeric(12,2)
);
ALTER TABLE cajero_automatico OWNER TO postgres;

CREATE TABLE cliente (
    id_cliente integer NOT NULL,
    nombre character varying(50),
    apellido character varying(50),
    dni character varying(15),
    direccion character varying(100),
    telefono character varying(20)
);
ALTER TABLE cliente OWNER TO postgres;

CREATE TABLE cuentabancaria (
    numero_cuenta character varying(20) NOT NULL,
    id_cliente integer,
    tipo_cuenta character varying(20),
    saldo_actual numeric(12,2),
    estado character varying(20),
    CONSTRAINT cuenta_numero_valido CHECK ((numero_cuenta ~ '^[0-9]+$'))
);
ALTER TABLE cuentabancaria OWNER TO postgres;

CREATE TABLE cuentas (
    codigo_cuenta integer NOT NULL,
    id_bancos integer,
    denominacion character varying(50)
);
ALTER TABLE cuentas OWNER TO postgres;

CREATE TABLE movimientos (
    id_movimientos integer NOT NULL,
    numero_cuenta character varying(20),
    id_cajero_automatico integer,
    id_retiro integer,
    codigo_cuenta integer,
    monto numeric(12,2),
    fecha timestamp without time zone
);
ALTER TABLE movimientos OWNER TO postgres;

CREATE TABLE retiro (
    id_retiro integer NOT NULL,
    numero_tarjeta character varying(19),
    id_cajero integer,
    fecha_hora timestamp without time zone,
    monto numeric(12,2),
    tipo_retiro character varying(20)
);
ALTER TABLE retiro OWNER TO postgres;

CREATE TABLE tarjeta (
    numero_tarjeta character varying(19) NOT NULL,
    numero_cuenta character varying(20),
    tipo_tarjeta character varying(20),
    fecha_expiracion date,
    estado character varying(20),
    CONSTRAINT tarjeta_numero_valido CHECK ((numero_tarjeta ~ '^[0-9]{13,19}$'))
);
ALTER TABLE tarjeta OWNER TO postgres;


-- ==================== FUNCIONES ====================

CREATE FUNCTION obtenermovimientos(numero_cuenta character varying)
  RETURNS TABLE(
    fecha timestamp without time zone,
    monto numeric,
    id_cajero integer,
    id_retiro integer,
    codigo_cuenta integer
  )
  LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
    SELECT Fecha, Monto, ID_Cajero_Automatico, ID_Retiro, Codigo_Cuenta
      FROM movimientos
     WHERE Numero_Cuenta = numero_cuenta
     ORDER BY Fecha DESC;
END;
$$;
ALTER FUNCTION obtenermovimientos(character varying) OWNER TO postgres;

CREATE FUNCTION obtenersaldo(numero_cuenta character varying)
  RETURNS numeric
  LANGUAGE plpgsql
AS $$
BEGIN
  RETURN (
    SELECT Saldo_Actual
      FROM cuentabancaria
     WHERE Numero_Cuenta = numero_cuenta
  );
END;
$$;
ALTER FUNCTION obtenersaldo(character varying) OWNER TO postgres;

CREATE FUNCTION obtenertarjetasporcliente(id_cliente integer)
  RETURNS TABLE(
    numero_tarjeta character varying,
    tipo_tarjeta character varying,
    fecha_expiracion date
  )
  LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
    SELECT t.Numero_Tarjeta, t.Tipo_Tarjeta, t.Fecha_Expiracion
      FROM tarjeta t
      JOIN cuentabancaria c ON t.Numero_Cuenta = c.Numero_Cuenta
     WHERE c.ID_Cliente = id_cliente
       AND t.Estado = 'Activa';
END;
$$;
ALTER FUNCTION obtenertarjetasporcliente(integer) OWNER TO postgres;


-- ==================== PROCEDIMIENTOS ====================

CREATE PROCEDURE realizardeposito(
  IN p_numero_cuenta character varying,
  IN p_id_cajero integer,
  IN p_monto numeric,
  IN p_codigo_cuenta integer
)
  LANGUAGE plpgsql
AS $$
DECLARE
  v_saldo decimal;
BEGIN
  SELECT Saldo_Actual
    INTO v_saldo
    FROM cuentabancaria
   WHERE Numero_Cuenta = p_numero_cuenta
     AND Estado = 'Activa';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cuenta no existe o no está activa.';
  END IF;

  INSERT INTO movimientos (
      Numero_Cuenta, ID_Cajero_Automatico, ID_Retiro,
      Codigo_Cuenta, Monto, Fecha
    )
    VALUES (
      p_numero_cuenta, p_id_cajero, NULL,
      p_codigo_cuenta, p_monto, NOW()
    );

  UPDATE cuentabancaria
     SET Saldo_Actual = Saldo_Actual + p_monto
   WHERE Numero_Cuenta = p_numero_cuenta;

  UPDATE cajero_automatico
     SET Monto_Cajero = Monto_Cajero + p_monto
   WHERE ID_Cajero_Automatico = p_id_cajero;
END;
$$;
ALTER PROCEDURE realizardeposito(character varying, integer, numeric, integer) OWNER TO postgres;

CREATE PROCEDURE realizarretiro(
  IN p_id_cliente integer,
  IN p_id_cajero integer,
  IN p_monto numeric
)
  LANGUAGE plpgsql
AS $$
DECLARE
  v_numero_cuenta varchar;
  v_saldo decimal;
  v_tarjeta varchar;
BEGIN
  SELECT t.Numero_Tarjeta, c.Numero_Cuenta, c.Saldo_Actual
    INTO v_tarjeta, v_numero_cuenta, v_saldo
    FROM tarjeta t
    JOIN cuentabancaria c ON t.Numero_Cuenta = c.Numero_Cuenta
   WHERE c.ID_Cliente = p_id_cliente
     AND t.Estado = 'Activa'
   LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'No se encontró una tarjeta activa.';
  END IF;

  IF v_saldo < p_monto THEN
    RAISE EXCEPTION 'Saldo insuficiente.';
  END IF;

  INSERT INTO retiro (Numero_Tarjeta, ID_Cajero, Fecha_Hora, Monto, Tipo_Retiro)
    VALUES (v_tarjeta, p_id_cajero, NOW(), p_monto, 'ATM');

  INSERT INTO movimientos (
      Numero_Cuenta, ID_Cajero_Automatico, ID_Retiro,
      Codigo_Cuenta, Monto, Fecha
    )
    VALUES (
      v_numero_cuenta, p_id_cajero, currval('retiro_id_retiro_seq'),
      10, p_monto, NOW()
    );

  UPDATE cuentabancaria
     SET Saldo_Actual = Saldo_Actual - p_monto
   WHERE Numero_Cuenta = v_numero_cuenta;

  UPDATE cajero_automatico
     SET Monto_Cajero = Monto_Cajero - p_monto
   WHERE ID_Cajero_Automatico = p_id_cajero;
END;
$$;
ALTER PROCEDURE realizarretiro(integer, integer, numeric) OWNER TO postgres;

CREATE PROCEDURE realizarretiro(
  IN p_numero_tarjeta character varying,
  IN p_id_cajero integer,
  IN p_monto numeric,
  IN p_tipo_retiro character varying,
  IN p_codigo_cuenta integer
)
  LANGUAGE plpgsql
AS $$
DECLARE
  v_numero_cuenta varchar;
  v_saldo_actual decimal;
BEGIN
  SELECT Numero_Cuenta
    INTO v_numero_cuenta
    FROM tarjeta
   WHERE Numero_Tarjeta = p_numero_tarjeta
     AND Estado = 'Activa';

  SELECT Saldo_Actual
    INTO v_saldo_actual
    FROM cuentabancaria
   WHERE Numero_Cuenta = v_numero_cuenta;

  IF v_saldo_actual < p_monto THEN
    RAISE EXCEPTION 'Saldo insuficiente';
  END IF;

  INSERT INTO retiro (Numero_Tarjeta, ID_Cajero, Fecha_Hora, Monto, Tipo_Retiro)
    VALUES (p_numero_tarjeta, p_id_cajero, NOW(), p_monto, p_tipo_retiro)
  RETURNING ID_Retiro INTO STRICT p_id_cajero;

  INSERT INTO movimientos (
      Numero_Cuenta, ID_Cajero_Automatico, ID_Retiro,
      Codigo_Cuenta, Monto, Fecha
    )
    VALUES (
      v_numero_cuenta, p_id_cajero, currval('retiro_id_retiro_seq'),
      p_codigo_cuenta, p_monto, NOW()
    );

  UPDATE cuentabancaria
     SET Saldo_Actual = Saldo_Actual - p_monto
   WHERE Numero_Cuenta = v_numero_cuenta;

  UPDATE cajero_automatico
     SET Monto_Cajero = Monto_Cajero - p_monto
   WHERE ID_Cajero_Automatico = p_id_cajero;
END;
$$;
ALTER PROCEDURE realizarretiro(character varying, integer, numeric, character varying, integer) OWNER TO postgres;

CREATE PROCEDURE realizartransferencia(
  IN p_id_cliente integer,
  IN p_id_cajero integer,
  IN p_numero_cuenta_destino character varying,
  IN p_monto numeric
)
  LANGUAGE plpgsql
AS $$
DECLARE
  v_numero_cuenta_origen varchar;
  v_saldo_origen decimal;
BEGIN
  SELECT Numero_Cuenta, Saldo_Actual
    INTO v_numero_cuenta_origen, v_saldo_origen
    FROM cuentabancaria
   WHERE ID_Cliente = p_id_cliente
     AND Estado = 'Activa'
   LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Cuenta origen no encontrada o inactiva.';
  END IF;

  IF v_saldo_origen < p_monto THEN
    RAISE EXCEPTION 'Saldo insuficiente en la cuenta origen.';
  END IF;

  IF NOT EXISTS (
      SELECT 1
        FROM cuentabancaria
       WHERE Numero_Cuenta = p_numero_cuenta_destino
         AND Estado = 'Activa'
    ) THEN
    RAISE EXCEPTION 'Cuenta destino no encontrada o inactiva.';
  END IF;

  UPDATE cuentabancaria
     SET Saldo_Actual = Saldo_Actual - p_monto
   WHERE Numero_Cuenta = v_numero_cuenta_origen;

  UPDATE cuentabancaria
     SET Saldo_Actual = Saldo_Actual + p_monto
   WHERE Numero_Cuenta = p_numero_cuenta_destino;

  INSERT INTO movimientos (
      Numero_Cuenta, ID_Cajero_Automatico, ID_Retiro,
      Codigo_Cuenta, Monto, Fecha
    )
    VALUES (
      v_numero_cuenta_origen, p_id_cajero, NULL,
      10, p_monto, NOW()
    );

  INSERT INTO movimientos (
      Numero_Cuenta, ID_Cajero_Automatico, ID_Retiro,
      Codigo_Cuenta, Monto, Fecha
    )
    VALUES (
      p_numero_cuenta_destino, p_id_cajero, NULL,
      10, p_monto, NOW()
    );
END;
$$;
ALTER PROCEDURE realizartransferencia(integer, integer, character varying, numeric) OWNER TO postgres;

CREATE PROCEDURE registrarcliente(
  IN p_nombre character varying,
  IN p_apellido character varying,
  IN p_dni character varying,
  IN p_direccion character varying,
  IN p_telefono character varying
)
  LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO cliente (Nombre, Apellido, DNI, Direccion, Telefono)
    VALUES (p_nombre, p_apellido, p_dni, p_direccion, p_telefono);
END;
$$;
ALTER PROCEDURE registrarcliente(character varying, character varying, character varying, character varying, character varying) OWNER TO postgres;

CREATE PROCEDURE registrarcuenta(
  IN p_numero_cuenta character varying,
  IN p_id_cliente integer,
  IN p_tipo_cuenta character varying,
  IN p_saldo_inicial numeric,
  IN p_estado character varying
)
  LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO cuentabancaria (Numero_Cuenta, ID_Cliente, Tipo_Cuenta, Saldo_Actual, Estado)
    VALUES (p_numero_cuenta, p_id_cliente, p_tipo_cuenta, p_saldo_inicial, p_estado);
END;
$$;
ALTER PROCEDURE registrarcuenta(character varying, integer, character varying, numeric, character varying) OWNER TO postgres;

