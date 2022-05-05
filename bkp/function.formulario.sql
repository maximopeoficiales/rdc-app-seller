--
-- PostgreSQL database dump
--

-- Dumped from database version 11.15
-- Dumped by pg_dump version 11.15

-- Started on 2022-05-05 20:08:54 UTC

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 239 (class 1255 OID 16385)
-- Name: fnc_obtiene_classification_products(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.fnc_obtiene_classification_products(vi_division_id character varying, vi_department_code character varying, vi_line_code character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE classification integer := 0;
BEGIN
    select a.classification_products_id into classification
    from public.classification_products a 
    where a.division_id  = vi_division_id and a.department_code  = vi_department_code 
    and a.line_code = vi_line_code
    limit 1;
   
   return classification;
END;
$$;


ALTER FUNCTION public.fnc_obtiene_classification_products(vi_division_id character varying, vi_department_code character varying, vi_line_code character varying) OWNER TO intcouriersusr;

--
-- TOC entry 240 (class 1255 OID 16386)
-- Name: fnt_get_git_card_white_list(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.fnt_get_git_card_white_list() RETURNS TABLE(dni character varying)	
    LANGUAGE plpgsql
    AS $$

BEGIN 

	RETURN QUERY  

        SELECT

            a.dni

	FROM git_card_white_list a 

	WHERE a.status = 1;

END;

$$;


ALTER FUNCTION public.fnt_get_git_card_white_list() OWNER TO intcouriersusr;

--
-- TOC entry 241 (class 1255 OID 16387)
-- Name: fnt_get_puchase_by_boleta(character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.fnt_get_puchase_by_boleta(nroboleta character varying) RETURNS TABLE(sucursal character varying, caja character varying, purchase_date character varying, transaccion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY
		select 
			p.sucursal,
			p.caja,
			to_char(to_date(p.purchase_date,'YYYY-MM-DD'), 'DD-MM-YYYY')::varchar as purchase_date,
			p.transaccion  
		from purchase p  where number_order 
		LIKE '%' || nroboleta||'%' limit 1;
END;
$$;


ALTER FUNCTION public.fnt_get_puchase_by_boleta(nroboleta character varying) OWNER TO intcouriersusr;

--
-- TOC entry 244 (class 1255 OID 16388)
-- Name: fnt_get_status_git_card(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.fnt_get_status_git_card() RETURNS integer
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_list_order_store

		| * Proposito   : Funcion para listar las ordenes de tiendas fisicas.

		| * Input Parameters:

		| * Output Parameters:

		|   - <fnt_get_status_git_card>       :Número entero 1 true. 0 false.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            RDC

		| ----------------------------------------------------------------------------

		| - 17/11/21    Rulman Ferro   Validar estado de gitcard      RQ 4657-14   

	************/

	declare

		status boolean :=false;

	BEGIN 

		select exists (SELECT

				a.status 

				FROM parameter_master a 

				WHERE a.parameter_id=3 and a.status = 1 ) into status;

		return status::int;

	END;

	$$;


ALTER FUNCTION public.fnt_get_status_git_card() OWNER TO intcouriersusr;

--
-- TOC entry 257 (class 1255 OID 16389)
-- Name: fnt_update_status_git_card(integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.fnt_update_status_git_card(in_status integer, OUT vo_msn character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_list_order_store

		| * Proposito   : Funcion para listar las ordenes de tiendas fisicas.

		| * Input Parameters:

		| * Output Parameters:

		|   - <fnt_get_status_git_card>       :Número entero 1 true. 0 false.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio                    RDC

		| ----------------------------------------------------------------------------

		| - 17/11/21    Rulman Ferro   Actualizar estado parameter_master     RQ 4657-14   

	************/

	BEGIN 

		UPDATE public.parameter_master SET status = in_status  WHERE parameter_id = 3;

		vo_msn:= 'Update Successfull!!';

	END

	$$;


ALTER FUNCTION public.fnt_update_status_git_card(in_status integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 258 (class 1255 OID 16390)
-- Name: sp_list_order_internet(character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_list_order_internet(vi_number_order character varying) RETURNS TABLE(estado_request integer[], estado character varying[], product_id character varying, quantity_products integer, quantity_products_return bigint, reason_operation_id integer, reason_operation text, operation_type_id integer, operation_type text, flag_offers integer, flag_returned integer, flag_blocking integer, type_blocking integer, description_blocking text, sub_title_fecha text, condition character varying, days_expiration integer, flag_mostrar integer)
    LANGUAGE plpgsql
    AS $$ DECLARE reg RECORD; n_purchase_id int:=0; n_order_master_id   int:=0; BEGIN  SELECT b.purchase_id, max(case when  a.estado_request not in (3,5) then coalesce(a.order_master_id, 0) else 0 end) into n_purchase_id, n_order_master_id FROM 	public.purchase b LEFT JOIN order_master a on a.purchase_id = b.purchase_id WHERE b.number_order = LPAD(vi_number_order, 15, '0') group by b.purchase_id ; IF n_order_master_id = 0 THEN RETURN QUERY select ARRAY_AGG(a.estado_request) as estado_request, ARRAY_AGG(a.id_qr) as estado, pd.product_id as product_id, MAX(coalesce(pd.quantity_products,0)) as quantity_products, SUM(coalesce(pd.quantity_products_return,0)) as quantity_products_return, 0 as reason_operation_id, '' as reason_operation, 0 as operation_type_id, '' as operation_type, 0 as flag_offers, 0 as flag_returned, MAX(case when to_date(pur.purchase_date,'yyyy-mm-dd') +/*coalesce(pd.days_expiration,60)*/ 5120< current_date then 1 when g.is_transport = 1 then 1 else 0 end) as flag_blocking, MAX(case when g.is_transport = 1 then 2 else 1 end) as type_blocking, MAX(case when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(pd.days_expiration,60)*/ 5120 < current_date then 'Pasó la fecha límite de devolución' when g.is_transport = 1 then 'Producto no transportable' else '-' end) as description_blocking, MAX(case when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(pd.days_expiration,60)*/ 5120 > current_date then 'Fec. límite de devolución: ' || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(pd.days_expiration,60)*/ 5120 <= current_date then 'Fec. límite de devolución: ' || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') else '-' end) as sub_title_fecha, (CASE WHEN (g.condition is null) THEN 'A' ELSE g.condition END) as condition, coalesce(pd.days_expiration,60) as days_expiration, g.mostrar as flag_mostrar FROM public.purchase pur inner join public.purchase_detail pd on pd.purchase_id = pur.purchase_id LEFT JOIN order_master a on a.purchase_id = pur.purchase_id left join public.classification_products g on g.classification_products_id  = pd.classification_products_id WHERE pur.purchase_id = n_purchase_id GROUP BY pd.product_id , g.condition, pd.days_expiration, g.mostrar, pd.suborder; ELSE RETURN QUERY SELECT ARRAY_AGG(a.estado_request) as estado_request, ARRAY_AGG(d.description) as estado, c.product_id as product_id, MAX(coalesce(c.quantity_products,0)) as quantity_products, SUM((case when a.estado_request = 4 then coalesce(c.quantity_products_return_real,0) else coalesce(c.quantity_products_return,0) end) ) as quantity_products_return, MAX(c.reason_operation_id) as reason_operation_id, MAX(f.description) as reason_operation, MAX(coalesce(c.operation_type_id,0)) as operation_type_id, MAX(e.description) as operation_type, MAX(coalesce(c.flag_offers,0)) as flag_offers, MAX(case when (case when a.estado_request = 4 then c.quantity_products_return_real else coalesce(c.quantity_products_return,0) end) <> 0 then 1 else 0 end) as flag_returned, MAX(case when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(c1.days_expiration,60)*/ 5120 < current_date then 1 when g.is_transport = 1 then 1 else 0 end) as flag_blocking, MAX(case when g.is_transport = 1 then 2 else 1 end) as type_blocking, MAX(case when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(c1.days_expiration,60)*/ 5120 < current_date then 'Pasó la fecha límite de devolución' when g.is_transport = 1 then 'Producto no transportable' else '-' end) as description_blocking, MAX(case when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(c1.days_expiration,60)*/ 5120 > current_date then 'Fec. límite de devolución: ' || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') when to_date(pur.purchase_date,'yyyy-mm-dd') + /*coalesce(c1.days_expiration,60)*/ 5120 <= current_date then 'Fec. límite de devolución: ' || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') else '-' end) as sub_title_fecha, (CASE WHEN (g.condition is null) THEN 'A' ELSE g.condition END) as condition, coalesce(c1.days_expiration,60) as days_expiration, g.mostrar as flag_mostrar FROM public.purchase pur INNER JOIN order_master a on a.purchase_id = pur.purchase_id INNER JOIN order_detail c ON c.order_master_id = a.order_master_id INNER JOIN purchase_detail c1 ON c1.product_id = c.product_id and c1.purchase_id = pur.purchase_id INNER JOIN state_movements d ON d.state_movements_id = a.estado_request INNER JOIN operation_type e ON e.operation_type_id = c.operation_type_id INNER JOIN reason_operation f ON f.reason_operation_id = c.reason_operation_id left join public.classification_products g on g.classification_products_id  = c1.classification_products_id WHERE pur.purchase_id = n_purchase_id    and a.estado_request in (2,4) GROUP BY c.product_id , g.condition, c1.days_expiration, g.mostrar, c.suborder; END IF; END $$;


ALTER FUNCTION public.sp_list_order_internet(vi_number_order character varying) OWNER TO intcouriersusr;

--
-- TOC entry 242 (class 1255 OID 16391)
-- Name: sp_list_order_store(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_list_order_store(vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaction character varying) RETURNS TABLE(estado_request integer[], estado character varying[], product_id character varying, quantity_products integer, quantity_products_return bigint, reason_operation_id integer, reason_operation text, operation_type_id integer, operation_type text, flag_offers integer, flag_returned integer, flag_blocking integer, type_blocking integer, description_blocking text, sub_title_fecha text, condition character varying, days_expiration integer, flag_mostrar integer)
    LANGUAGE plpgsql
    AS $$

		/*************

		| * Descripcion : FUNCTION public.sp_list_order_store

		| * Proposito   : Función para listar las ordenes de tiendas fisicas.

		| * Input Parameters:

		|   - <vi_sucursal>                           		:Sucursal.

		|   - <vi_caja>                           			:Caja.

		|   - <vi_purchase_date>                           	:Fecha de compra.

		|   - <vi_transaction>                           	:Transaccion.

		| * Output Parameters:

		|   - <estado_request>                                 :Estado de solicitud.

		|   - <estado>                                         :Estado.

		|   - <product_id>                                     :ID del producto.

		|   - <quantity_products>                              :Cantidad de productos.

		|   - <quantity_products_return>                       :Cantidad de productos devueltos.

		|   - <reason_operation_id>                            :Sucursal.

		|   - <reason_operation>                               :Monto.

		|   - <operation_type_id>                              :Monto afecto.

		|   - <operation_type>                                 :Tipo de operación.

		|   - <flag_offers>                                    :Bandera de oferta.

		|   - <flag_returned>                                  :Bandera de retorno.

		|   - <flag_blocking>                                  :Bandera de bloqueo.

		|   - <type_blocking>                                  :Tipo de bloqueo.

		|   - <description_blocking>                           :Descripción de bloqueo.

		|   - <condition>                                      :Condición.

		|   - <days_expiration>                                :Días de expiración.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14   

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            RDC

		| ----------------------------------------------------------------------------

		| - 17/11/21    Rulman Ferro   Listar orden de compra        RQ 4657-14       

		************/

	DECLARE

		reg RECORD;

		n_purchase_id       int:=0; 

		n_order_master_id   int:=0;

	BEGIN 

	

	  SELECT b.purchase_id,

	   max(case when  a.estado_request not in (3,5) then coalesce(a.order_master_id, 0) else 0 end) into n_purchase_id, n_order_master_id

	  FROM     public.purchase b

	  LEFT JOIN order_master a

	  on a.purchase_id = b.purchase_id

	  WHERE b.sucursal = LPAD(vi_sucursal, 6, '0') AND

	        b.caja = LPAD(vi_caja, 6, '0') AND

	        b.purchase_date = to_char(to_date(vi_purchase_date,'dd-mm-yyyy'), 'yyyy-mm-dd') AND

	        b.transaccion = LPAD(vi_transaction, 6, '0')

	  GROUP BY b.purchase_id;

	  

	 

	 IF n_order_master_id = 0 THEN

	  RETURN QUERY  

		 select 

				ARRAY_AGG(a.estado_request) as estado_request, 

				ARRAY_AGG(a.id_qr) as estado, 

				pd.product_id as product_id, 

				MAX(coalesce(pd.quantity_products,0)) as quantity_products, 

				SUM(coalesce(pd.quantity_products_return,0)) as quantity_products_return,

				0 as reason_operation_id,

				'' as reason_operation,

				0 as operation_type_id,

				'' as operation_type, 

				0 as flag_offers,

				0 as flag_returned,

				MAX(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) < current_date then 1  

					 when g.is_transport = 1 then 1

					 else 0

					end) as flag_blocking,

			    MAX(case    

					 when g.is_transport = 1 then 2

					 else 1 

					end) as type_blocking,

				MAX(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) < current_date then 'Pasó la fecha límite de devolución' 

					 when g.is_transport = 1 then 'Producto no transportable' 

					 else '-'

					end) as description_blocking,

				MAX(case 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60)> current_date then /*INICIO CAMBIO RQ 4657-14*/ 'Fec. límite: ' /*FIN CAMBIO RQ 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') 

					 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60) <= current_date then /*INICIO CAMBIO RQ 4657-14*/'Fec. límite: ' /*FIN CAMBIO RQ 4657-14*/|| to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(pd.days_expiration,60), 'dd/mm/yyyy') 

					 else '-'

					end) as sub_title_fecha ,

					(CASE WHEN (g.condition is null) THEN 'A' ELSE g.condition END) as condition,

					coalesce(pd.days_expiration,60) as days_expiration,

					g.mostrar as flag_mostrar

			FROM public.purchase pur 

			inner join public.purchase_detail pd 

			on pd.purchase_id = pur.purchase_id 

			LEFT JOIN order_master a

			on a.purchase_id = pur.purchase_id   

			left join public.classification_products g

			on g.classification_products_id  = pd.classification_products_id 

			  WHERE pur.purchase_id = n_purchase_id 

			GROUP BY pd.product_id , g.condition, pd.days_expiration, g.mostrar  ; 	  

	 ELSE	

	  RETURN QUERY  

			SELECT 

			ARRAY_AGG(a.estado_request) as estado_request, 

			ARRAY_AGG(d.description) as estado, 

			c.product_id as product_id, 

			MAX(coalesce(c.quantity_products,0)) as quantity_products, 

			SUM((case when a.estado_request = 4 then coalesce(c.quantity_products_return_real,0)

				            else 

				 coalesce(c.quantity_products_return,0)

				       end)

			) as quantity_products_return,

			MAX(c.reason_operation_id) as reason_operation_id,

			MAX(f.description) as reason_operation,

			MAX(coalesce(c.operation_type_id,0)) as operation_type_id,

			MAX(e.description) as operation_type, 

			MAX(coalesce(c.flag_offers,0)) as flag_offers,

			MAX(case 

				 when (case when a.estado_request = 4 then c.quantity_products_return_real 

				           else coalesce(c.quantity_products_return,0)

				       end) <> 0 then 1 

				 else 0

				end) as flag_returned,

			MAX(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) < current_date then 1  

			     when g.is_transport = 1 then 1

				 else 0 

				end) as flag_blocking,

			MAX(case    

				 when g.is_transport = 1 then 2

				 else 1 

				end) as type_blocking,

			MAX(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) < current_date then 'Pasó la fecha límite de devolución'  

				 when g.is_transport = 1 then 'Producto no transportable' 

				 else '-'

				end) as description_blocking,

			MAX(case 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) > current_date then /*INICIO CAMBIO RQ 4657-14*/'Fec. límite: '/*FIN CAMBIO RQ 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') 

				 when to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60) <= current_date then /*INICIO CAMBIO RQ 4657-14*/'Fec. límite: ' /*FIN CAMBIO RQ 4657-14*/ || to_char(to_date(pur.purchase_date,'yyyy-mm-dd') + coalesce(c1.days_expiration,60), 'dd/mm/yyyy') 

				 else '-'

				end) as sub_title_fecha,

				(CASE WHEN (g.condition is null) THEN 'A' ELSE g.condition END) as condition,

		   coalesce(c1.days_expiration ,60) as days_expiration,

		   g.mostrar as flag_mostrar

		FROM public.purchase pur 

		INNER JOIN order_master a

		on a.purchase_id = pur.purchase_id  

		INNER JOIN order_detail c

		ON c.order_master_id = a.order_master_id

		INNER JOIN purchase_detail c1

		ON c1.product_id = c.product_id

		   and c1.purchase_id = pur.purchase_id 

		INNER JOIN state_movements d

		ON d.state_movements_id = a.estado_request

		INNER JOIN operation_type e

		ON e.operation_type_id = c.operation_type_id

		INNER JOIN reason_operation f

		ON f.reason_operation_id = c.reason_operation_id

	    left join public.classification_products g

		on g.classification_products_id  = c1.classification_products_id 

		  WHERE pur.purchase_id = n_purchase_id  and a.estado_request in (2,4)

		GROUP BY c.product_id , g.condition, c1.days_expiration, g.mostrar ;

	 END IF;

					 

	END

	$$;


ALTER FUNCTION public.sp_list_order_store(vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaction character varying) OWNER TO intcouriersusr;

--
-- TOC entry 259 (class 1255 OID 16393)
-- Name: sp_list_products_by_order(bigint); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_list_products_by_order(orderid bigint) RETURNS TABLE(product_id character varying, quantity_products integer, quantity_products_return integer, quantity_products_return_real integer)
    LANGUAGE plpgsql
    AS $$
BEGIN 
 RETURN QUERY 
 select 
	od.product_id, 
	od.quantity_products, 
	od.quantity_products_return,
	(case when od.quantity_products_return_real is null then 0
		 else od.quantity_products_return_real
		 end ) as quantity_products_return_real
 from order_detail od
 where od.order_master_id = orderid;
END;
$$;


ALTER FUNCTION public.sp_list_products_by_order(orderid bigint) OWNER TO intcouriersusr;

--
-- TOC entry 260 (class 1255 OID 16394)
-- Name: sp_listar_detail_email_for_send(integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_detail_email_for_send(ni_order_master_id integer) RETURNS TABLE(order_detail_id bigint, order_master_id bigint, product_type_id bigint, product_id character varying, quantity_products integer, quantity_products_return integer, monto numeric, monto_affected numeric, operation_type_id integer, reason_operation_id integer, product_url character varying, flag_offers integer, offers character varying, product character varying, classification_products_id bigint, model character varying, size character varying, image character varying, brand character varying, quantity_products_return_real integer, monto_affected_real numeric, flag_return integer, price_by_unit numeric, days_expiration integer, expiration_date date, seller_name character varying)
    LANGUAGE plpgsql
    AS $$

 /*************

  | * Descripcion : FUNCTION public.sp_listar_detail_email_for_send

  | * Proposito   : Funcion para obtener el detalle de los correos.

  | * Input Parameters:

  | * Output Parameters:

  |   - <order_detail_id>                   :ID del detalle de la orden.

  |   - <order_master_id>                    :ID de la orden creada en el formulario.

  |   - <product_type_id>                      :Tipo del producto.

  |   - <product_id>                 :Identificador del producto.

  |   - <quantity_products>                 			:Cantidad de productos.

  |   - <quantity_products_return>                  :Cantidad de productos a retornar.

  |   - <monto>                     :Monto.

  |   - <monto_affected>                   :Monto afectado.

  |   - <operation_type_id>            :Tipo de operacion.

  |   - <reason_operation_id>            :Motivo de devolucion.

  |   - <product_url>            :Url del producto.

  |   - <flag_offers>                       :Estado de la oferta.

  |   - <offers>                :Oferta.

  |   - <product>                :Nombre del producto.

  |   - <classification_products_id>                    :ID clasificacion del producto.

  |   - <model>                   :Modelo del producto.

  |   - <size>                             :Talla del producto.

  |   - <image>                       :Imagen del producto.

  |   - <brand>                   		:Marca del producto.

  |   - <quantity_products_return_real>                  :Cantidad del productos.

  |   - <monto_affected_real>                          :Monto afectado.

  |   - <flag_return>                      :Estado de retorno.

  |   - <price_by_unit_total>                :Precio total.

  |   - <days_expiration>                :Dias de expiracion.

  |   - <expiration_date>                :Fecha de expiracion.

  |   - <seller_name>                :Nombre del vendedor.

  | * Autor       : Gianmarcos Perez Rojas.

  | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

  | * Responsable : Cesar Jimenez.

  | * RDC         : RQ-4657-8

  |

  | * Revisiones

  | * Fecha            Autor       Motivo del cambio            RDC

  | ----------------------------------------------------------------------------

  | - 14/09/21    Gianmarcos Perez Se agrega sucursal y trx     RQ 4657-8   

  | - 30/03/22    Paulo Carbajal Nombre del vendedor            RQ 4707-4                                                             

  ************/

DECLARE

    r order_detail%rowtype; 

    d_purchase_date  date;

    n_purchase_id    int8;

BEGIN

	select a.purchase_date, a.purchase_id into d_purchase_date, n_purchase_id

	from order_master a 

	left join purchase b 

	on b.purchase_id = a.purchase_id 

    where a.order_master_id = ni_order_master_id;



   RETURN QUERY  

        SELECT a.order_detail_id, a.order_master_id, a.product_type_id, a.product_id, a.quantity_products, 

         a.quantity_products_return, a.monto, a.monto_affected, a.operation_type_id, a.reason_operation_id, 

         a.product_url, a.flag_offers, a.offers, a.product, a.classification_products_id, a.model, a.size, a.image, 

         a.brand, a.quantity_products_return_real, a.monto_affected_real, a.flag_return, a.price_by_unit_total,

         coalesce(pd.days_expiration, 60) as days_expiration, d_purchase_date + coalesce(pd.days_expiration, 60) expiration_date,

         a.seller_name 

        FROM order_detail a

        LEFT JOIN purchase_detail pd 

        ON pd.product_id = a.product_id and 

           pd.purchase_id  = n_purchase_id and
           pd.suborder = pd.suborder 

        WHERE a.order_master_id = ni_order_master_id AND

		a.quantity_products_return > 0;

END;

$$;


ALTER FUNCTION public.sp_listar_detail_email_for_send(ni_order_master_id integer) OWNER TO intcouriersusr;

--
-- TOC entry 261 (class 1255 OID 16396)
-- Name: sp_listar_email_for_send(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_email_for_send() RETURNS TABLE(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_idd integer, category character varying, method_id integer, bar_code character varying, email_option character varying, state_email_option integer, forma_pago character varying)
    LANGUAGE plpgsql
    AS $$

  /*************

  | * Descripcion : FUNCTION public.sp_listar_email_for_send

  | * Proposito   : Funcion para listart los correos que faltan enviar.

  | * Input Parameters:

  | * Output Parameters:

  |   - <order_master_id>                   :ID del detalle de la orden.

  |   - <prospect_order>                    :ID de la orden creada en el formulario.

  |   - <order_number>                      :Número de orden.

  |   - <identity_document>                 :Documento de indentidad.

  |   - <email>                 			:Email.

  |   - <purchase_type_id>                  :Id tipo de compra.

  |   - <purchase_date>                     :Fecha de compra.

  |   - <number_products>                   :Número de productos.

  |   - <number_products_unique>            :Número de productos únicos.

  |   - <number_products_return>            :Número de productos devuelos.

  |   - <number_products_change>            :Número de productos cambiados.

  |   - <monto_total>                       :Monto total.

  |   - <monto_total_return>                :Monto total devuelto.

  |   - <monto_total_change>                :Monto total de cambio.

  |   - <estado_request>                    :Estado de la solicitud.

  |   - <flag_send_email>                   :Bandera de correo enviado.

  |   - <id_qr>                             :ID del qr.

  |   - <category_id>                       :ID de categoria.

  |   - <category>                   		:Categoria.

  |   - <return_method_id>                  :ID de metodo de devolución.

  |   - <bar_code>                          :Código de barra.

  |   - <email_option>                      :Correo opcional.

  |   - <state_email_option>                :Estado del correo opcional.

  | * Autor       : Gianmarcos Perez Rojas.

  | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

  | * Responsable : Cesar Jimenez.

  | * RDC         : RQ-4657-8

  |

  | * Revisiones

  | * Fecha            Autor       Motivo del cambio            RDC

  | ----------------------------------------------------------------------------

  | - 14/09/21    Gianmarcos Perez Se agrega sucursal y trx     RQ 4657-8                                                             

  ************/

DECLARE 

	n_solicitudes_pendientes integer := 2;

      	

BEGIN 

 

    update order_master x set category_id = 

	  (select max(case when b.division_id = 'G02' then 9

	            when a.reason_operation_id = 4 then 7

	            else 3

	           end 

	          ) 

	    from order_detail a 

	    inner join purchase_detail  b 

	    on b.product_id  = a.product_id 

	    and b.purchase_id = x.purchase_id 

	    left join classification_products c 

	    on c.classification_products_id = a.classification_products_id 

	  where a.order_master_id = x.order_master_id  AND

		a.quantity_products_return > 0)

     where x.estado_request = n_solicitudes_pendientes ;

    --Actualizamos electro de 9 a 2 

    update order_master x set category_id = 2 where category_id = 9;

    --Actualizamos fallado de 7 a 1

	update order_master x set category_id = 1 where category_id = 7;

	RETURN QUERY  

        SELECT a.order_master_id,

			a.prospect_order,

			a.order_number,

			a.identity_document,

			a.email,

			a.purchase_type_id,

			a.purchase_date,

			a.number_products,

			a.number_products_unique,

			a.number_products_return,

			a.number_products_change,

			a.monto_total,

			a.monto_total_return,

			a.monto_total_change,

			a.estado_request,

			a.flag_send_email,

			a.id_qr,

			a.category_id,

			b.description as category,

			a.return_method_id,

			a.bar_code,

			a.email_option,

			a.state_email_option,

			p.forma_pago 

	FROM order_master a

	join purchase p on p.purchase_id = a.purchase_id 

	left join order_category b

	on b.order_category_id = a.category_id 

	WHERE a.estado_request = n_solicitudes_pendientes  ;

END;

$$;


ALTER FUNCTION public.sp_listar_email_for_send() OWNER TO intcouriersusr;

--
-- TOC entry 262 (class 1255 OID 16398)
-- Name: sp_listar_email_for_send_faild(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_email_for_send_faild() RETURNS TABLE(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_id integer, category character varying, method_id integer, bar_code character varying, person_first_name character varying, person_last_name character varying, person_identity_document character varying, created_at timestamp with time zone, email_client character varying, name_client character varying, intentos bigint)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_listar_email_for_send_faild

		| * Proposito   : Función para listar correos reintento.

		| * Input Parameters:

		| * Output Parameters:

		|   - <order_master_id>            :Id order master.

		|   - <prospect_order>             :Prospecto de la orden.

		|   - <order_number>               :Número de orden.

		|   - <identity_document>          :Documento de identidad.

		|   - <email>                      :Email.

		|   - <purchase_type_id>           :Id de tipo de compra.

		|   - <purchase_date>              :Fecha de compra.

		|   - <number_products>            :Número de productos.

		|   - <number_products_unique>     :Número de productos únicos.

		|   - <number_products_return>     :Número de productos devueltos.

		|   - <number_products_change>     :Número de productos cambiados.

		|   - <monto_total>                :Monto total.

		|   - <monto_total_return>         :Monto total devuelto.

		|   - <monto_total_change>         :Monto total de cambio.

		|   - <estado_request>             :Estado de la solicitud.

		|   - <flag_send_email>            :Bandera de envio de correo.

		|   - <id_qr>                      :Id de código de barras.

		|   - <category_id>                :Id de categoria.

		|   - <category>                   :Categoria.

		|   - <return_method_id>           :Id de metodo de compra.

		|   - <bar_code>                   :Código de barras.

		|   - <person_first_name>          :Nombre de la persona devolución a terceros.

		|   - <person_last_name>           :Apellidos de la persona devolución a terceros.

		|   - <person_identity_document>   :Documento de identidad de la persona devolución a terceros.

		|   - <created_at>                 :Fecha de la solicitud.

		|   - <email_client>               :Correo del cliente de compra online.

		|   - <name_client>               :Nombre del cliente de compra online.

		|   - <intentos>                   :Número de intentos.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            			RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Rulman Ferro   Listar correos que no se enviaron      RQ 4657-14

	************/

	DECLARE 

		n_solicitudes_pendientes integer := 5;

	BEGIN 

		

		update send_email set  status_code = 8 where status_code = 2;

		

		RETURN QUERY  

			SELECT a.order_master_id,

				a.prospect_order,

				a.order_number,

				a.identity_document,

				c.destination_email as email,

				a.purchase_type_id,

				a.purchase_date,

				a.number_products,

				a.number_products_unique,

				a.number_products_return,

				a.number_products_change,

				a.monto_total,

				a.monto_total_return,

				a.monto_total_change,

				a.estado_request,

				a.flag_send_email,

				a.id_qr,

				a.category_id,

				b.description as category,

				a.return_method_id,

				a.bar_code,

				a.person_first_name ,

				a.person_last_name ,

				a.person_identity_document ,

				a.created_at,

				/*INICIO CAMBIO RQ 4657-14*/

				p.email_client,

				p.name_client,

				/*FIN CAMBIO RQ 4657-14*/

				count(distinct c.order_master_id) as intentos

		FROM order_master a 

		left join order_category b

		on b.order_category_id = a.category_id

		inner JOIN send_email c

		ON c.order_master_id = a.order_master_id

		join purchase p ON p.purchase_id = a.purchase_id 

		WHERE a.estado_request in (5,6) and c.status_code = 8 and a.flag_send_email_security = 0

		GROUP BY a.order_master_id,

				a.prospect_order,

				a.order_number,

				a.identity_document,

				c.destination_email,

				a.purchase_type_id,

				a.purchase_date,

				a.number_products,

				a.number_products_unique,

				a.number_products_return,

				a.number_products_change,

				a.monto_total,

				a.monto_total_return,

				a.monto_total_change,

				a.estado_request,

				a.flag_send_email,

				a.id_qr,

				a.category_id,

				b.description,

				a.return_method_id,

				a.bar_code,

				a.person_first_name ,

				a.person_last_name ,

				a.person_identity_document ,

				a.created_at,

				/*INICIO CAMBIO RQ 4657-14*/

				p.email_client,

				p.name_client

				/*FIN CAMBIO RQ 4657-14*/

		HAVING count(c.order_master_id) < 4;

	END;

	$$;


ALTER FUNCTION public.sp_listar_email_for_send_faild() OWNER TO intcouriersusr;

--
-- TOC entry 263 (class 1255 OID 16400)
-- Name: sp_listar_email_for_send_security(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_email_for_send_security() RETURNS TABLE(order_master_id bigint, prospect_order bigint, order_number character varying, identity_document character varying, email character varying, purchase_type_id integer, purchase_date date, number_products integer, number_products_unique integer, number_products_return integer, number_products_change integer, monto_total numeric, monto_total_return numeric, monto_total_change numeric, estado_request integer, flag_send_email integer, id_qr character varying, category_idd integer, category character varying, method_id integer, bar_code character varying, email_option character varying, state_email_option integer, person_first_name character varying, person_last_name character varying, person_identity_document character varying, name_client character varying, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_list_order_store

		| * Proposito   : Funcion para listar las ordenes de tiendas fisicas.

		| * Input Parameters:

		| * Output Parameters:

		|   - <order_master_id>            :Id order master.

		|   - <prospect_order>             :Prospecto de la orden.

		|   - <order_number>               :Número de orden.

		|   - <identity_document>          :Documento de identidad.

		|   - <email>                      :Correo de la persona que realizo la compra online..

		|   - <purchase_type_id>           :Id de tipo de compra.

		|   - <purchase_date>              :Fecha de compra.

		|   - <number_products>            :Número de productos.

		|   - <number_products_unique>     :Número de productos únicos.

		|   - <number_products_return>     :Número de productos devueltos.

		|   - <number_products_change>     :Número de productos cambiados.

		|   - <monto_total>                :Monto total.

		|   - <monto_total_return>         :Monto total devuelto.

		|   - <monto_total_change>         :Monto total de cambio.

		|   - <estado_request>             :Estado de la solicitud.

		|   - <flag_send_email>            :Bandera de envio de correo.

		|   - <id_qr>                      :Id de código de barras.

		|   - <category_id>                :Id de categoria.

		|   - <category>                   :Categoria.

		|   - <return_method_id>           :Id de metodo de compra.

		|   - <bar_code>                   :Código de barras.

		|   - <person_first_name>          :Nombre de la persona devolución a terceros.

		|   - <person_last_name>           :Apellidos de la persona devolución a terceros.

		|   - <person_identity_document>   :Documento de identidad de la persona devolución a terceros.

		|   - <name_client>   			   :Nombre del cliente de compra online.

		|   - <created_at>                 :Fecha de la solicitud.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14   

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio                 RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez Listar de correos de seguridad    RQ 4657-14

	************/

	DECLARE 

		n_flag_send_email_security integer := 0;

			

	BEGIN 

		RETURN QUERY  

			SELECT a.order_master_id,

				a.prospect_order,

				a.order_number,

				a.identity_document,

				p.email_client as email,

				a.purchase_type_id,

				a.purchase_date,

				a.number_products,

				a.number_products_unique,

				a.number_products_return,

				a.number_products_change,

				a.monto_total,

				a.monto_total_return,

				a.monto_total_change,

				a.estado_request,

				a.flag_send_email,

				a.id_qr,

				a.category_id,

				b.description as category,

				a.return_method_id,

				a.bar_code,

				a.email_option,

				a.state_email_option,

				a.person_first_name,

				a.person_last_name,

				a.person_identity_document,

				p.name_client,

				a.created_at

		FROM order_master a 

		join purchase p on p.purchase_id =a.purchase_id 

		left join order_category b on b.order_category_id = a.category_id 

		WHERE p.email_client is not null and p.email_client != '' and a.flag_send_email_security = n_flag_send_email_security and p.sucursal='000060' and p.caja='000120';

	END;

	$$;


ALTER FUNCTION public.sp_listar_email_for_send_security() OWNER TO intcouriersusr;

--
-- TOC entry 264 (class 1255 OID 16402)
-- Name: sp_listar_order_detail_x_tikect(character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_order_detail_x_tikect(vi_tikect character varying) RETURNS TABLE(order_master_id bigint, order_number character varying, product_name character varying, reason_name character varying, quantity_products_return integer, price_by_unit numeric, product_color character varying, product_size character varying)
    LANGUAGE plpgsql
    AS $$

BEGIN 

	RETURN QUERY  

        SELECT om.order_master_id, om.order_number, od.product as product_name, ro.description reason_name,od.quantity_products_return, od.price_by_unit, od.color as product_color, od."size"  as product_size 

		from order_master om

		join order_detail od on od.order_master_id = om.order_master_id 

		join reason_operation ro on ro.reason_operation_id = od.reason_operation_id 

		where od.quantity_products_return > 0 and om.order_number = vi_tikect;

END;

$$;


ALTER FUNCTION public.sp_listar_order_detail_x_tikect(vi_tikect character varying) OWNER TO intcouriersusr;

--
-- TOC entry 196 (class 1259 OID 16403)
-- Name: order_master_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.order_master_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_master_seq OWNER TO intcouriersusr;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 197 (class 1259 OID 16405)
-- Name: order; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public."order" (
    order_id bigint DEFAULT nextval('public.order_master_seq'::regclass) NOT NULL,
    prospect_order bigint NOT NULL,
    order_number character varying(30) NOT NULL,
    identity_document character varying(20) NOT NULL,
    email character varying(80) NOT NULL,
    purchase_type_id integer NOT NULL,
    purchase_date date NOT NULL,
    number_products integer NOT NULL,
    number_products_unique integer,
    number_products_return integer,
    number_products_change integer,
    amount_total numeric(14,4) NOT NULL,
    amount_total_return numeric(14,4),
    amount_total_change numeric(14,4),
    estado_request integer DEFAULT 2,
    flag_send_email integer DEFAULT 0,
    id_qr character varying(8000),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_id date DEFAULT CURRENT_DATE,
    coordinates character varying(30),
    category_id integer DEFAULT 3,
    type_return_id integer,
    return_method_id integer,
    bar_code character varying(250),
    ip_address character varying(80),
    purchase_id bigint,
    email_option character varying(80),
    state_email_option integer DEFAULT 0,
    person_return integer,
    person_first_name character varying(80),
    person_last_name character varying(80),
    person_identity_document character varying(20),
    flag_send_email_security integer DEFAULT 0,
    type_order character varying,
    phone character varying
);


ALTER TABLE public."order" OWNER TO intcouriersusr;

--
-- TOC entry 3214 (class 0 OID 0)
-- Dependencies: 197
-- Name: COLUMN "order".phone; Type: COMMENT; Schema: public; Owner: intcouriersusr
--

COMMENT ON COLUMN public."order".phone IS '# de telefono del usuario';


--
-- TOC entry 265 (class 1255 OID 16419)
-- Name: sp_listar_order_details_x_order(integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_order_details_x_order(ni_order_id integer) RETURNS SETOF public."order"
    LANGUAGE plpgsql
    AS $$
DECLARE
    r order_master%rowtype;
BEGIN
    FOR r IN
        SELECT * FROM order_detail WHERE order_master_id = ni_order_id
    LOOP 
        RETURN NEXT r;  
    END LOOP;
    RETURN;
END;
$$;


ALTER FUNCTION public.sp_listar_order_details_x_order(ni_order_id integer) OWNER TO intcouriersusr;

--
-- TOC entry 266 (class 1255 OID 16420)
-- Name: sp_listar_order_x_tikect(character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_listar_order_x_tikect(vi_tikect character varying) RETURNS SETOF public."order"
    LANGUAGE plpgsql
    AS $$
DECLARE
    r order_master%rowtype;
BEGIN
    FOR r IN
        SELECT * FROM order_master WHERE order_number = vi_tikect
    LOOP 
        RETURN NEXT r;  
    END LOOP;
    RETURN;
END;
$$;


ALTER FUNCTION public.sp_listar_order_x_tikect(vi_tikect character varying) OWNER TO intcouriersusr;

--
-- TOC entry 267 (class 1255 OID 16421)
-- Name: sp_migra_order_detail_msa(integer, integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_migra_order_detail_msa(ni_order_master_ini_id integer, ni_order_master_fin_id integer) RETURNS TABLE(order_master_id bigint, ean character varying, flag_cambio integer, cantidad integer, cantidad_return integer, precio numeric, precio_affected numeric, descuento_articulo integer, descuento_boleta character varying, product character varying, reason_operation_id integer, reason_operation character varying, operation_type_id integer, operation_type character varying, model character varying, size_product character varying, image character varying, brand character varying, price_by_unit numeric, is_enchufable integer, is_transport integer, days_expiration integer, expiration_date text, price_by_unit_total numeric, promotion character varying, promotion_code character varying, condition character varying, color character varying, code_delivery character varying, mode_delivery character varying, time_of_purchase character varying, seller_id character varying, seller_name character varying, suborder character varying, type_product character varying)
    LANGUAGE plpgsql
    AS $$

DECLARE

    r order_master%rowtype;

begin

	/*************

  | * Descripcion : FUNCTION public.sp_migra_order_detail_msa

  | * Proposito   : Funcion para traer el detalle de las ordenes

  | * Input Parameters:

  |   - <ni_order_master_ini_id> :Numero de ID ticket inicial.

  |   - <ni_order_master_fin_id> :Numero de ID ticket final.

  | * Output Parameters:

  |   - <order_master_id>      :Id de la orden detalle.

  |   - <ean>                   :Id producto.

  |   - <flag_cambio>                 :Estado de cambio

  |   - <cantidad>                :Cantidad

  |   - <cantidad_return>                :Cantidad a retornar

  |   - <precio>        :Precio

  |   - <precio_affected>             :Precio afectado.

  |   - <descuento_articulo>                :Descuento articulo.

  |   - <descuento_boleta>                 :Descuento boleta.

  |   - <reason_operation_id>               :Id motivo de devolucion.

  |   - <reason_operation>                 :Motivo de devolucion.

  |   - <operation_type_id>            :Tipo de operacion.

  |   - <model>                :Modelo.

  |   - <size_product>                :Tamano del producto.

  |   - <image>        :Imagen del producto.

  |   - <brand>         :Marca del producto.

  |   - <price_by_unit>      :Precio por unidad.

  |   - <is_enchufable>      :Tipo enchufable.

  |   - <is_transport>  :Producto transportable.

  |   - <days_expiration>             :Dias de expiracion.

  |   - <expiration_date>             :Fecha de expiracion.

  |   - <price_by_unit_total>             :Precio por unidad.

  |   - <promotion>             :Promocion.

  |   - <promotion_code>             :Codigo de promocion.

  |   - <condition>             :Condicion.

  |   - <color>             :Color.

  |   - <code_delivery>             :Codigo de delivery.

  |   - <mode_delivery>             :Modo de delivery.

  |   - <time_of_purchase>             :Fecha de compra.

  |   - <seller_id>             :ID del vendedor.

  |   - <seller_name>             :Nombre del vendedor.

  |   - <suborder>             :Suborden.

  |   - <type_product>             :Tipo de producto marketplace o ripley.

  | * Autor       : Paulo Carbajal.

  | * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

  | * Responsable : Cesar Jimenez.

  | * RDC         : RQ-4657-15

  |

  | * Revisiones

  | * Fecha            Autor       Motivo del cambio                 RDC

  | ----------------------------------------------------------------------------

  | - 30/03/22    Paulo Carbajal   Se agrega el seller id, nombre, suborden y tipo de producto             RQ 4707-4

				                                     

************/       

	RETURN QUERY  

        SELECT a.order_master_id, a.product_id as ean,

			a.operation_type_id as flag_cambio,

			a.quantity_products as cantidad,

			a.quantity_products_return as cantidad_return,

			a.monto as precio,

			a.monto_affected as precio_affected,

			a.flag_offers as descuento_articulo,

			a.offers as descuento_boleta,

			a.product,

			a.reason_operation_id,

			c.description AS reason_operation,

			a.operation_type_id,

			b.description as operation_type,

			a.model model,

			a.size size_product,

			a.product_url image,

			a.brand,

			a.price_by_unit,

			d.is_enchufable,

			d.is_transport,

			coalesce(a1.days_expiration, 60) as days_expiration,

			to_char(ord.purchase_date + coalesce(a1.days_expiration, 60) , 'YYYY-MM-DD') as expiration_date,

			a.price_by_unit_total,

			a.promotion,

			a.promotion_code,

			(CASE WHEN (d.condition is null) THEN 'A' ELSE d.condition END) as condition,

			a1.color,

			a1.code_delivery,

			a1.mode_delivery,

			a1.time_of_purchase,

			a1.seller_id ,

			a1.seller_name ,

			a1.suborder ,

			a1.type_product 

        FROM order_detail a

        inner join public.order_master ord 

        on ord.order_master_id  = a.order_master_id 

        inner join purchase_detail a1

        on a1.product_id = a.product_id and

           a1.purchase_id = ord.purchase_id 

		left join public.operation_type b

		on b.operation_type_id = a.operation_type_id

		left join public.reason_operation c

		on c.reason_operation_id = a.reason_operation_id

		left join public.classification_products d

		on d.classification_products_id = a.classification_products_id 

		WHERE a.order_master_id >= ni_order_master_ini_id and

		   a.order_master_id <= ni_order_master_fin_id;

END;

$$;


ALTER FUNCTION public.sp_migra_order_detail_msa(ni_order_master_ini_id integer, ni_order_master_fin_id integer) OWNER TO intcouriersusr;

--
-- TOC entry 268 (class 1255 OID 16423)
-- Name: sp_migra_order_msa(integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_migra_order_msa(ni_order_master_id integer) RETURNS TABLE(order_master_id bigint, order_number character varying, number_order character varying, caja character varying, sucursal character varying, purchase_date character varying, transaccion character varying, monto_total numeric, monto_total_return numeric, purchase_type_id integer, purchase_type character varying, identity_document character varying, return_method_id integer, email character varying, purchase_id bigint, numero_documento bigint, cud character varying, forma_pago character varying, email_option character varying, name_client character varying, person_first_name character varying, person_last_name character varying, person_identity_document character varying, category_id integer, phone character varying)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_migra_order_msa

		| * Proposito   : Función para migrar datos de formulario a cayde.

		| * Input Parameters:

		|   - <ni_order_master_id>              :Id orden compra.

		| * Output Parameters:

		|   - <order_master_id>                 :Id order master.

		|   - <nro_ticket>             			:Número de ticket.

		|   - <nro_boleta>               		:Número de boleta.

		|   - <nro_caja>          			    :Número de caja.

		|   - <nro_sucursal>                    :Número de sucursal.

		|   - <fecha>             				:Fecha de compra.

		|   - <nro_transaccion>                 :Número de transacción.

		|   - <monto_total>          			:Monto total.

		|   - <monto_total_return>              :Monto total devuelto.

		|   - <purchase_type_id>             	:Id tipo compra.

		|   - <purchase_type>                   :Tipo de compra.

		|   - <identity_document>          		:Documento de identidad.

		|   - <method_id>                       :Id Metodo devolución.

		|   - <email>             				:Correo.

		|   - <purchase_id>                     :Id de compra.

		|   - <numero_documento>          		:Número de documento.

		|   - <cud>                             :Cud.

		|   - <forma_pago>             			:Forma de pago.

		|   - <email_option>                    :Correo opcional.

		|   - <name_client>          			:Nombre del cliente.

		|   - <person_first_name>               :Nombre devolucion a terceros.

		|   - <person_last_name>             	:Apellidos devolucion a terceros.

		|   - <person_identity_document>        :Número de documento devolucion a terceros.

		|   - <category_id>          			:Id Categoria.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor             Motivo del cambio            RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez       Agregar category_id    RQ 4657-14

	************/

DECLARE

   -- r order_master%rowtype;

BEGIN

	RETURN QUERY  

        SELECT a.order_master_id, a.order_number as nro_ticket,

			coalesce(pur.number_order, b1.number_order) as nro_boleta,

			pur.caja as nro_caja,

			pur.sucursal as nro_sucursal,

			pur.purchase_date as fecha,

			pur.transaccion as nro_transaccion,

			a.monto_total as monto_total,

			a.monto_total_return as monto_total_return,

			a.purchase_type_id,

			c.description as purchase_type,

			a.identity_document,

			a.return_method_id as method_id,

			a.email,

			a.purchase_id,

			pur.number_document as numero_documento,

			pur.cud as cud,

			pur.forma_pago as forma_pago,

			a.email_option,

			pur.name_client,

			a.person_first_name ,

			a.person_last_name ,

			a.person_identity_document,

			/*INICIO CAMBIO RQ 4657-14*/

			a.category_id,

			/*INICIO CAMBIO RQ 4657-14*/

			a.phone 

        FROM order_master a

        inner join public.purchase pur

        on pur.purchase_id = a.purchase_id 

		LEFT JOIN order_purchase_internet b1

		ON b1.order_master_id = a.order_master_id 

		LEFT JOIN order_purchase_store b2

		ON b2.order_master_id = a.order_master_id

		LEFT JOIN public.purchase_type c

		ON c.purchase_type_id = a.purchase_type_id

		WHERE a.order_master_id > ni_order_master_id;

END;

$$;


ALTER FUNCTION public.sp_migra_order_msa(ni_order_master_id integer) OWNER TO intcouriersusr;

--
-- TOC entry 269 (class 1255 OID 16425)
-- Name: sp_product_blocked(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_product_blocked() RETURNS TABLE(cod_product character varying, product_name character varying, price double precision)
    LANGUAGE plpgsql
    AS $$

BEGIN 

	RETURN QUERY  

        SELECT

            a.cod_product,

	    a.product_name,

	    a.price

	 

	FROM product_blocked a 

	WHERE a.status = 1;

END;

$$;


ALTER FUNCTION public.sp_product_blocked() OWNER TO intcouriersusr;

--
-- TOC entry 270 (class 1255 OID 16426)
-- Name: sp_save_email_option(character varying, integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_email_option(email_option_save character varying, id_order_master integer) RETURNS TABLE(state_email_option integer)
    LANGUAGE plpgsql
    AS $$

	BEGIN
	
		update order_master  set  estado_request = 2 , email_option = email_option_save , state_email_option  = 1 where order_master_id = id_order_master;
	
	RETURN QUERY  
	
        SELECT o.state_email_option 
		
	FROM order_master o
	WHERE o.order_master_id = id_order_master  ;
	
	END; 
$$;


ALTER FUNCTION public.sp_save_email_option(email_option_save character varying, id_order_master integer) OWNER TO intcouriersusr;

--
-- TOC entry 271 (class 1255 OID 16427)
-- Name: sp_save_order(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, numeric, numeric, integer, character varying, integer, character varying, integer, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_order(ni_prospectorder integer, ni_purchasetypeid integer, vi_numberorder character varying, vi_sucursal character varying, vi_caja character varying, vi_purchasedate character varying, vi_identitdocument character varying, vi_transacsion character varying, vi_email character varying, ni_numberproducts integer, ni_numberproductsreturn integer, ni_montototal numeric, ni_montototalchange numeric, ni_estadorequest integer, vi_coordinates character varying, ni_return_method_id integer, vi_ip character varying, ni_purchase_id integer, vi_person_return integer, vi_person_first_name character varying, vi_person_last_name character varying, vi_person_identity_document character varying, vi_type_order character varying) RETURNS TABLE(order_master_id bigint, tikect text, identity_document character varying, email character varying)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_save_order

		| * Proposito   : Función para guardar orden de compra.

		| * Input Parameters:

		|   - <ni_prospectorder>               :Prospecto de la orden.

		|   - <ni_purchasetypeid>              :Id de tipo de compra.

		|   - <vi_numberorder>                 :Número de orden.

		|   - <vi_sucursal>                    :Código de sucursal.

		|   - <vi_caja>                        :Código de caja.

		|   - <vi_purchasedate>                :Fecha de compra.

		|   - <vi_identitdocument>             :Documento de identidad.

		|   - <vi_transacsion>                 :Número de transacción.

		|   - <vi_email>                       :Correo.

		|   - <ni_numberproducts>              :Número de productos.

		|   - <ni_numberproductsreturn>        :Número de productos devueltos.

		|   - <ni_montototal>                  :Monto total.

		|   - <ni_montototalchange>            :Monto total de cambio.

		|   - <ni_estadorequest>               :Estado de la solicitud.

		|   - <vi_coordinates>                 :Coordenadas.

		|   - <ni_return_method_id>            :Id metodo de devolución.

		|   - <vi_ip>                          :Ip.

		|   - <ni_purchase_id>                 :Id de compra.

		|   - <vi_person_return>               :Bandera de devolución a terceros.

		|   - <vi_person_first_name>           :Nombre de devolución a terceros.

		|   - <vi_person_last_name>            :Apellidos de devolución a terceros.

		|   - <vi_person_identity_document>    :Documento de identidad devolución a terceros.

		|   = <vi_type_order>                  : Si es una orden de marketplace o ripley.

		| * Output Parameters:

		|   - <order_master_id>                 :Id order master.

		|   - <tikect>             				:Número de ticket.

		|   - <identity_document>               :Documento de identidad.

		|   - <email>          					:Correo.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez Guardar orde de compra    RQ 4657-14

	************/

	DECLARE

		reg RECORD;

		n_seq      bigint := nextval('order_master_seq');

		n_seq_mov  bigint := nextval('order_movements_seq');

		v_tikect   text; 

		n_status_movemnts  integer :=2;

		v_email_client  text := null;

	BEGIN 

		v_tikect := cast(n_seq as varchar) ;

		v_tikect := lpad(v_tikect,6,'0');

		v_tikect := 'T-'||v_tikect;

		INSERT INTO order_movements(

		order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

		VALUES (n_seq_mov, n_seq, CURRENT_TIMESTAMP, n_status_movemnts, 'TESS'); 

		INSERT INTO order_master(

			order_master_id, prospect_order, order_number, identity_document, email, purchase_type_id,  

			purchase_date, number_products, number_products_unique, number_products_return, 

			number_products_change, monto_total, monto_total_return, monto_total_change, estado_request, 

			flag_send_email, id_qr,  coordinates, type_return_id, return_method_id, ip_address, purchase_id,

			/*INICIO CAMBIO RQ 4657-14*/

			person_return, person_first_name, person_last_name, person_identity_document, type_order)

			/*FIN CAMBIO RQ 4657-14*/

		VALUES (n_seq, ni_prospectorder, v_tikect, vi_identitdocument, vi_email, ni_purchasetypeid, 

		

				TO_DATE(vi_purchasedate,'YYYY-MM-DD'), ni_numberproducts, 0, ni_numberproductsreturn, 

				0, ni_montototal, 0, ni_montototalchange, n_status_movemnts, 

				0, 

				'https://chart.googleapis.com/chart?cht=qr&chs=350x350&chld=H&choe=UTF-8&chl=%7B%0A%22clientDni%22+%3A+%22vi_identitdocument%22%2C%0A%22ticketNumber%22%3A+%22v_tikect%22%0A%7D',  

				vi_coordinates, ni_return_method_id, ni_return_method_id, vi_ip, ni_purchase_id,

				/*INICIO CAMBIO RQ 4657-14*/

				vi_person_return,

				vi_person_first_name,

				vi_person_last_name,

				vi_person_identity_document,

			    vi_type_order);

			/*INICIO CAMBIO RQ 4657-14*/

		update purchase set email= vi_email where  purchase_id= ni_purchase_id;

		case 

			when ni_purchasetypeid = 1 then /*Internet*/ 

				INSERT INTO order_purchase_internet(

				order_master_id, number_order)

				VALUES (n_seq, vi_numberorder);

			when ni_purchasetypeid = 2 then /*Tienda*/

				INSERT INTO order_purchase_store(

				order_master_id, sucursal, caja, purchase_date, transaccion)

				VALUES (n_seq, vi_sucursal, vi_caja, vi_purchasedate, vi_transacsion);

			end case;

		RETURN QUERY  

		SELECT n_seq as order_master_id , v_tikect tikect, vi_identitdocument as identity_document,

		vi_email as email;  

	END

	$$;


ALTER FUNCTION public.sp_save_order(ni_prospectorder integer, ni_purchasetypeid integer, vi_numberorder character varying, vi_sucursal character varying, vi_caja character varying, vi_purchasedate character varying, vi_identitdocument character varying, vi_transacsion character varying, vi_email character varying, ni_numberproducts integer, ni_numberproductsreturn integer, ni_montototal numeric, ni_montototalchange numeric, ni_estadorequest integer, vi_coordinates character varying, ni_return_method_id integer, vi_ip character varying, ni_purchase_id integer, vi_person_return integer, vi_person_first_name character varying, vi_person_last_name character varying, vi_person_identity_document character varying, vi_type_order character varying) OWNER TO intcouriersusr;

--
-- TOC entry 272 (class 1255 OID 16429)
-- Name: sp_save_order(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, numeric, numeric, integer, character varying, integer, character varying, integer, integer, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_order(ni_prospectorder integer, ni_purchasetypeid integer, vi_numberorder character varying, vi_sucursal character varying, vi_caja character varying, vi_purchasedate character varying, vi_identitdocument character varying, vi_transacsion character varying, vi_email character varying, ni_numberproducts integer, ni_numberproductsreturn integer, ni_montototal numeric, ni_montototalchange numeric, ni_estadorequest integer, vi_coordinates character varying, ni_return_method_id integer, vi_ip character varying, ni_purchase_id integer, vi_person_return integer, vi_person_first_name character varying, vi_person_last_name character varying, vi_person_identity_document character varying, vi_type_order character varying, vi_phone character varying) RETURNS TABLE(order_master_id bigint, tikect text, identity_document character varying, email character varying, phone character varying)
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_save_order

		| * Proposito   : Función para guardar orden de compra.

		| * Input Parameters:

		|   - <ni_prospectorder>               :Prospecto de la orden.

		|   - <ni_purchasetypeid>              :Id de tipo de compra.

		|   - <vi_numberorder>                 :Número de orden.

		|   - <vi_sucursal>                    :Código de sucursal.

		|   - <vi_caja>                        :Código de caja.

		|   - <vi_purchasedate>                :Fecha de compra.

		|   - <vi_identitdocument>             :Documento de identidad.

		|   - <vi_transacsion>                 :Número de transacción.

		|   - <vi_email>                       :Correo.

		|   - <ni_numberproducts>              :Número de productos.

		|   - <ni_numberproductsreturn>        :Número de productos devueltos.

		|   - <ni_montototal>                  :Monto total.

		|   - <ni_montototalchange>            :Monto total de cambio.

		|   - <ni_estadorequest>               :Estado de la solicitud.

		|   - <vi_coordinates>                 :Coordenadas.

		|   - <ni_return_method_id>            :Id metodo de devolución.

		|   - <vi_ip>                          :Ip.

		|   - <ni_purchase_id>                 :Id de compra.

		|   - <vi_person_return>               :Bandera de devolución a terceros.

		|   - <vi_person_first_name>           :Nombre de devolución a terceros.

		|   - <vi_person_last_name>            :Apellidos de devolución a terceros.

		|   - <vi_person_identity_document>    :Documento de identidad devolución a terceros.

		|   = <vi_type_order>                  : Si es una orden de marketplace o ripley.
		|	- <vi_phone>					   :Telefono de usuario

		| * Output Parameters:

		|   - <order_master_id>                 :Id order master.

		|   - <tikect>             				:Número de ticket.

		|   - <identity_document>               :Documento de identidad.

		|   - <email>          					:Correo.
		|	- <phone>							:Telefono

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez Guardar orde de compra    RQ 4657-14

	************/

	DECLARE

		reg RECORD;

		n_seq      bigint := nextval('order_master_seq');

		n_seq_mov  bigint := nextval('order_movements_seq');

		v_tikect   text; 

		n_status_movemnts  integer :=2;

		v_email_client  text := null;

	BEGIN 

		v_tikect := cast(n_seq as varchar) ;

		v_tikect := lpad(v_tikect,6,'0');

		v_tikect := 'T-'||v_tikect;

		INSERT INTO order_movements(

		order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

		VALUES (n_seq_mov, n_seq, CURRENT_TIMESTAMP, n_status_movemnts, 'TESS'); 

		INSERT INTO order_master(

			order_master_id, prospect_order, order_number, identity_document, email, purchase_type_id,  

			purchase_date, number_products, number_products_unique, number_products_return, 

			number_products_change, monto_total, monto_total_return, monto_total_change, estado_request, 

			flag_send_email, id_qr,  coordinates, type_return_id, return_method_id, ip_address, purchase_id,

			/*INICIO CAMBIO RQ 4657-14*/

			person_return, person_first_name, person_last_name, person_identity_document, type_order,phone)

			/*FIN CAMBIO RQ 4657-14*/

		VALUES (n_seq, ni_prospectorder, v_tikect, vi_identitdocument, vi_email, ni_purchasetypeid, 

		

				TO_DATE(vi_purchasedate,'YYYY-MM-DD'), ni_numberproducts, 0, ni_numberproductsreturn, 

				0, ni_montototal, 0, ni_montototalchange, n_status_movemnts, 

				0, 

				'https://chart.googleapis.com/chart?cht=qr&chs=350x350&chld=H&choe=UTF-8&chl=%7B%0A%22clientDni%22+%3A+%22vi_identitdocument%22%2C%0A%22ticketNumber%22%3A+%22v_tikect%22%0A%7D',  

				vi_coordinates, ni_return_method_id, ni_return_method_id, vi_ip, ni_purchase_id,

				/*INICIO CAMBIO RQ 4657-14*/

				vi_person_return,

				vi_person_first_name,

				vi_person_last_name,

				vi_person_identity_document,

			    vi_type_order,
			   	vi_phone);

			/*INICIO CAMBIO RQ 4657-14*/

		update purchase set email= vi_email where  purchase_id= ni_purchase_id;

		case 

			when ni_purchasetypeid = 1 then /*Internet*/ 

				INSERT INTO order_purchase_internet(

				order_master_id, number_order)

				VALUES (n_seq, vi_numberorder);

			when ni_purchasetypeid = 2 then /*Tienda*/

				INSERT INTO order_purchase_store(

				order_master_id, sucursal, caja, purchase_date, transaccion)

				VALUES (n_seq, vi_sucursal, vi_caja, vi_purchasedate, vi_transacsion);

			end case;

		RETURN QUERY  

		SELECT n_seq as order_master_id , v_tikect tikect, vi_identitdocument as identity_document,

		vi_email as email, vi_phone as phone;  

	END

	$$;


ALTER FUNCTION public.sp_save_order(ni_prospectorder integer, ni_purchasetypeid integer, vi_numberorder character varying, vi_sucursal character varying, vi_caja character varying, vi_purchasedate character varying, vi_identitdocument character varying, vi_transacsion character varying, vi_email character varying, ni_numberproducts integer, ni_numberproductsreturn integer, ni_montototal numeric, ni_montototalchange numeric, ni_estadorequest integer, vi_coordinates character varying, ni_return_method_id integer, vi_ip character varying, ni_purchase_id integer, vi_person_return integer, vi_person_first_name character varying, vi_person_last_name character varying, vi_person_identity_document character varying, vi_type_order character varying, vi_phone character varying) OWNER TO intcouriersusr;

--
-- TOC entry 273 (class 1255 OID 16431)
-- Name: sp_save_purchase(character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, integer, numeric, character varying, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_purchase(vi_identit_document character varying, vi_email character varying, vi_number_order character varying, vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaccion character varying, ni_number_document integer, ni_comercio integer, ni_purchase_type_id integer, ni_number_products integer, ni_number_products_unique integer, ni_number_products_return integer, ni_mount numeric, vi_coordinates character varying, ni_credit_notes integer, vi_ip character varying, vi_cud character varying, vi_forma_pago character varying, vi_name_client character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    reg RECORD;
	n_seq      bigint := 0;  
	n_status   int := 1;  
    n_cantidad int8:=0;
BEGIN
    vo_ind:= 0;
    vo_msn:= 'Se registro correctamente!!';
    
    select d.purchase_id into vo_purchase_id
    from public.purchase d
    where d.sucursal = LPAD(vi_sucursal, 6, '0') and 
     d.caja = LPAD(vi_caja, 6, '0') and 
     d.purchase_date = vi_purchase_date and 
     d.transaccion = LPAD(vi_transaccion, 6, '0') and 
     d.number_order = LPAD(vi_number_order, 15, '0')
    limit 1;
   
    if vo_purchase_id is not null then 
	    vo_ind:= 2;
	    vo_msn:= 'Ya se encuentra registrado!!';
	   return;
    end if;
    
    n_seq := nextval('purchase_seq');
    vo_purchase_id:= n_seq;
 
    INSERT INTO public.purchase
	(purchase_id,identity_document, email, number_order, sucursal, caja, purchase_date, transaccion, number_document, comercio, 
	 purchase_type_id, number_products, number_products_unique, number_products_return, monto_total, status, 
	 coordinates, credit_notes, ip_address, cud, forma_pago, name_client)
	VALUES(n_seq, vi_identit_document, vi_email, LPAD(vi_number_order, 15, '0'), 
	      LPAD(vi_sucursal, 6, '0'), LPAD(vi_caja, 6, '0'), vi_purchase_date, 
          LPAD(vi_transaccion, 6, '0'), ni_number_document, ni_comercio, ni_purchase_type_id, ni_number_products, ni_number_products_unique, 
          ni_number_products_return, ni_mount, n_status, vi_coordinates, ni_credit_notes, vi_ip, vi_cud, vi_forma_pago, vi_name_client );

END
$$;


ALTER FUNCTION public.sp_save_purchase(vi_identit_document character varying, vi_email character varying, vi_number_order character varying, vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaccion character varying, ni_number_document integer, ni_comercio integer, ni_purchase_type_id integer, ni_number_products integer, ni_number_products_unique integer, ni_number_products_return integer, ni_mount numeric, vi_coordinates character varying, ni_credit_notes integer, vi_ip character varying, vi_cud character varying, vi_forma_pago character varying, vi_name_client character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 274 (class 1255 OID 16432)
-- Name: sp_save_purchase(character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, integer, integer, numeric, character varying, integer, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_purchase(vi_identit_document character varying, vi_email character varying, vi_number_order character varying, vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaccion character varying, ni_number_document integer, ni_comercio integer, ni_purchase_type_id integer, ni_number_products integer, ni_number_products_unique integer, ni_number_products_return integer, ni_mount numeric, vi_coordinates character varying, ni_credit_notes integer, vi_ip character varying, vi_cud character varying, vi_forma_pago character varying, vi_name_client character varying, vi_email_client character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_save_purchase

		| * Proposito   : Función para guardar compra.

		| * Input Parameters:

		|   - <vi_identit_document>              	:Documento de identidad.

		|   - <vi_email>              				:Correo.

		|   - <vi_number_order>                 	:Número de orden.

		|   - <vi_sucursal>                    		:Código de sucursal.

		|   - <vi_caja>                        		:Código de caja.

		|   - <vi_purchase_date>                	:Fecha de compra.

		|   - <vi_transaccion>             			:Número de transacción.

		|   - <ni_number_document>                  :Número de documento.

		|   - <ni_comercio>                         :Comercio.

		|   - <ni_purchase_type_id>                 :Id tipo de compra.

		|   - <ni_number_products>        			:Número de productos.

		|   - <ni_number_products_unique>           :Número de productos únicos.

		|   - <ni_number_products_return>           :Número de productos devueltos.

		|   - <ni_mount>               				:Monto.

		|   - <vi_coordinates>                 		:Coordenadas.

		|   - <ni_credit_notes>            			:Nota de credito.

		|   - <vi_ip>                          		:Ip.

		|   - <vi_cud>                 				:Id de compra.

		|   - <vi_forma_pago>               		:Forma de pago.

		|   - <vi_name_client>           			:Nombre del cliente compra online.

		|   - <vi_email_client>            			:Correo del cliente compra online.

		| * Output Parameters:

		|   - <vo_purchase_id>                		:Id de la compra.

		|   - <vo_ind>             				    :Número de estado.

		|   - <vo_msn>               				:Mensaje de respuesta.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor       Motivo del cambio            RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez Se agrega sucursal y trx     RQ 4657-14

	************/

	DECLARE

		reg RECORD;

		n_seq      bigint := 0;  

		n_status   int := 1;  

		n_cantidad int8:=0;

	BEGIN

		vo_ind:= 0;

		vo_msn:= 'Se registro correctamente!!';

		

		select d.purchase_id into vo_purchase_id

		from public.purchase d

		where d.sucursal = LPAD(vi_sucursal, 6, '0') and 

		d.caja = LPAD(vi_caja, 6, '0') and 

		d.purchase_date = vi_purchase_date and 

		d.transaccion = LPAD(vi_transaccion, 6, '0') and 

		d.number_order = LPAD(vi_number_order, 15, '0')

		limit 1;



		if vo_purchase_id is not null then 

		vo_ind:= 2;

		vo_msn:= 'Ya se encuentra registrado!!';

		return;

		end if;

		

		n_seq := nextval('purchase_seq');

		vo_purchase_id:= n_seq;



		INSERT INTO public.purchase

		(purchase_id,identity_document, email, number_order, sucursal, caja, purchase_date, transaccion, number_document, comercio, 

		purchase_type_id, number_products, number_products_unique, number_products_return, monto_total, status, 

		coordinates, credit_notes, ip_address, cud, forma_pago/*INICIO CAMBIO RQ 4657-14*/, name_client, email_client /*FIN CAMBIO RQ 4657-14*/)

		VALUES(n_seq, vi_identit_document, vi_email, LPAD(vi_number_order, 15, '0'), 

			LPAD(vi_sucursal, 6, '0'), LPAD(vi_caja, 6, '0'), vi_purchase_date, 

			LPAD(vi_transaccion, 6, '0'), ni_number_document, ni_comercio, ni_purchase_type_id, ni_number_products, ni_number_products_unique, 

			ni_number_products_return, ni_mount, n_status, vi_coordinates, ni_credit_notes, vi_ip, vi_cud, vi_forma_pago/*INICIO CAMBIO RQ 4657-14*/, vi_name_client,vi_email_client /*FIN CAMBIO RQ 4657-14*/);



	END

	$$;


ALTER FUNCTION public.sp_save_purchase(vi_identit_document character varying, vi_email character varying, vi_number_order character varying, vi_sucursal character varying, vi_caja character varying, vi_purchase_date character varying, vi_transaccion character varying, ni_number_document integer, ni_comercio integer, ni_purchase_type_id integer, ni_number_products integer, ni_number_products_unique integer, ni_number_products_return integer, ni_mount numeric, vi_coordinates character varying, ni_credit_notes integer, vi_ip character varying, vi_cud character varying, vi_forma_pago character varying, vi_name_client character varying, vi_email_client character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 275 (class 1255 OID 16434)
-- Name: sp_save_purchase_detail(integer, character varying, integer, numeric, character varying, character varying, character varying, character varying, character varying, numeric, character varying, character varying, character varying, character varying, character varying, integer, integer, character varying, integer, numeric, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_purchase_detail(ni_purchase_id integer, vi_product_id character varying, ni_quantity_products integer, ni_mount numeric, vi_product_url character varying, vi_product character varying, vi_model character varying, vi_size character varying, vi_brand character varying, ni_price_by_unit numeric, vi_division_id character varying, vi_area_id character varying, vi_departamento_id character varying, vi_linea_id character varying, vi_sub_linea_id character varying, ni_itemn_number integer, ni_promotion_code integer, vi_promotion character varying, ni_cupon_number integer, ni_promotion_discount_amount numeric, vi_color character varying, vi_code_delivery character varying, vi_mode_delivery character varying, vi_time_of_purchase character varying, vi_suborder character varying, vi_type_product character varying, vi_seller_name character varying, vi_seller_id character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$

DECLARE

    reg RECORD;

	n_seq      bigint := nextval('purchase_detail_seq');  

	n_status   int := 1;  

	n_classification_id   int:=0; 

    n_days_expiration     int:=0;

    n_not_enchufable_days int:=0;

    n_enchufable_days     int:=0;

BEGIN

    vo_ind:= 0;

    vo_msn:= 'Se registro correctamente!!';

    vo_purchase_id:= n_seq;

    --n_classification_id := public.fnc_obtiene_classification_products(vi_division_id, vi_departamento_id, vi_linea_id);

    /**No enchufable*/

   

   select a.classification_products_id,  (case when a.plazo = 'A' then 0 when a.plazo = 'B' then 7 when a.plazo = 'C' then 60 else 60 end)

      into n_classification_id, n_days_expiration

    from public.classification_products a 

    where a.division_id  = UPPER(TRIM(vi_division_id)) and a.department_code  = UPPER(TRIM(vi_departamento_id))

    and a.line_code = UPPER(TRIM(vi_linea_id))

    limit 1;

   

    INSERT INTO public.purchase_detail

	(purchase_detail_id, purchase_id, product_type_id, product_id, quantity_products,  

	monto, product_url, product, model, "size", brand, 

	price_by_unit, division_id, area_id, departamento_id, linea_id, sub_linea_id, 

	classification_products_id, itemn_number, promotion_code, promotion, cupon_number, 

	promotion_discount_amount, days_expiration, color, code_delivery, mode_delivery, time_of_purchase, suborder, type_product, seller_name, seller_id)

    VALUES(n_seq, ni_purchase_id, 1, vi_product_id, ni_quantity_products, 

      ni_mount, vi_product_url, vi_product, vi_model, vi_size, vi_brand, 

      ni_price_by_unit, vi_division_id, vi_area_id, vi_departamento_id, vi_linea_id, vi_sub_linea_id, 

	  n_classification_id, ni_itemn_number, ni_promotion_code, vi_promotion, ni_cupon_number, 

      ni_promotion_discount_amount, n_days_expiration, vi_color, vi_code_delivery, vi_mode_delivery, vi_time_of_purchase, vi_suborder, vi_type_product, vi_seller_name, vi_seller_id);



END

$$;


ALTER FUNCTION public.sp_save_purchase_detail(ni_purchase_id integer, vi_product_id character varying, ni_quantity_products integer, ni_mount numeric, vi_product_url character varying, vi_product character varying, vi_model character varying, vi_size character varying, vi_brand character varying, ni_price_by_unit numeric, vi_division_id character varying, vi_area_id character varying, vi_departamento_id character varying, vi_linea_id character varying, vi_sub_linea_id character varying, ni_itemn_number integer, ni_promotion_code integer, vi_promotion character varying, ni_cupon_number integer, ni_promotion_discount_amount numeric, vi_color character varying, vi_code_delivery character varying, vi_mode_delivery character varying, vi_time_of_purchase character varying, vi_suborder character varying, vi_type_product character varying, vi_seller_name character varying, vi_seller_id character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 276 (class 1255 OID 16435)
-- Name: sp_save_purchase_return(bigint, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, numeric, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_purchase_return(purchase_id bigint, vi_number_order character varying, vi_sucursal character varying, vi_caja character varying, vi_purchase_return_date character varying, vi_transaccion character varying, ni_number_document integer, ni_comercio integer, ni_number_products integer, ni_number_products_unique integer, ni_mount numeric, vi_ip character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    reg RECORD;
	n_seq      bigint := nextval('purchase_return_seq');  
	n_status   int := 1;  
BEGIN
    vo_ind:= 0;
    vo_msn:= 'Se registro correctamente!!';
    vo_purchase_id:= n_seq;
 
    INSERT INTO public.purchase_return
    (purchase_return_id, purchase_id, number_order, sucursal, caja, purchase_return_date, transaccion, 
     number_document, comercio, number_products, number_products_unique, 
     monto_total, status, ip_address)
      VALUES(n_seq, purchase_id, vi_number_order, vi_sucursal, vi_caja, vi_purchase_return_date, vi_transaccion, 
       ni_number_document, ni_comercio, ni_number_products, ni_number_products_unique, ni_mount, n_status, vi_ip
      );


END
$$;


ALTER FUNCTION public.sp_save_purchase_return(purchase_id bigint, vi_number_order character varying, vi_sucursal character varying, vi_caja character varying, vi_purchase_return_date character varying, vi_transaccion character varying, ni_number_document integer, ni_comercio integer, ni_number_products integer, ni_number_products_unique integer, ni_mount numeric, vi_ip character varying, OUT vo_purchase_id integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 277 (class 1255 OID 16436)
-- Name: sp_save_purchase_return_detail(integer, character varying, integer, numeric, integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_purchase_return_detail(ni_purchase_id integer, vi_product_id character varying, ni_quantity_products integer, ni_price_by_unit numeric, ni_itemn_number integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    reg RECORD;  
BEGIN
    vo_ind:= 0;
    vo_msn:= 'Se registro correctamente!!'; 
    
	INSERT INTO public.purchase_return_detail
	(purchase_id, product_id, quantity_products, mount, itemn_number)
	VALUES(ni_purchase_id, vi_product_id, ni_quantity_products, ni_price_by_unit, ni_itemn_number);


END
$$;


ALTER FUNCTION public.sp_save_purchase_return_detail(ni_purchase_id integer, vi_product_id character varying, ni_quantity_products integer, ni_price_by_unit numeric, ni_itemn_number integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 278 (class 1255 OID 16437)
-- Name: sp_save_send_email(integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_send_email(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$

DECLARE

    reg RECORD;

	n_seq     bigint := nextval('order_movements_seq');

	v_tikect  text; 

BEGIN 

    vo_ind:= 0;

    vo_msn:= 'Se registro correctamente!!';

   

    if ni_send_success = 1 then	

	    update send_email set status_code = 9 

		where order_master_id = ni_order_master_id and status_code = 8;

    end if;

	

	INSERT INTO order_movements(

	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

	VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, 5, 'TESS'); 

	INSERT INTO send_email(

	request_movements_id, order_master_id, 

	affair, destination_email, emails_cc, state_code_send, send_success, status_code)

	VALUES (n_seq, ni_order_master_id, 

			vi_asunto, vi_destination_email, vi_emails_cc, 5, ni_send_success, ni_send_success);

			

    update order_master set estado_request = 5 where order_master_id = ni_order_master_id;

	

END

$$;


ALTER FUNCTION public.sp_save_send_email(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 279 (class 1255 OID 16438)
-- Name: sp_save_send_email_purchase(integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_send_email_purchase(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$

DECLARE

    reg RECORD;

	n_seq     bigint := nextval('order_movements_seq');

	v_tikect  text; 

BEGIN 

    vo_ind:= 0;

    vo_msn:= 'Se registro correctamente!!';

   

    if ni_send_success = 1 then	

	    update send_email set status_code = 9 where order_master_id = ni_order_master_id and status_code = 8;

    	update order_master set flag_send_email_purchase = 1 where order_master_id = ni_order_master_id;

    end if;

	

	INSERT INTO order_movements(

	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

	VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, 6, 'TESS'); 

	INSERT INTO send_email(

	request_movements_id, order_master_id, 

	affair, destination_email, emails_cc, state_code_send, send_success, status_code)

	VALUES (n_seq, ni_order_master_id, vi_asunto, vi_destination_email, vi_emails_cc, 6, ni_send_success, ni_send_success);

			

	

END

$$;


ALTER FUNCTION public.sp_save_send_email_purchase(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 280 (class 1255 OID 16439)
-- Name: sp_save_send_email_security(integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_send_email_security(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$

	/*************

		| * Descripcion : FUNCTION public.sp_list_order_store

		| * Proposito   : Funcion para listar las ordenes de tiendas fisicas.

		| * Input Parameters:

		|   - <ni_order_master_id>              	:Id de orden de compra.

		|   - <ni_send_success>              		:Estado del correo.

		|   - <vi_asunto>                 			:Asunto de correo.

		|   - <vi_destination_email>                :Destino del correo.

		|   - <vi_emails_cc>                        :Copia del correo.

		| * Output Parameters:

		|   - <vo_ind>             				    :Número de estado.

		|   - <vo_msn>               				:Mensaje de respuesta.

		| * Autor       : Gianmarcos Perez Rojas.

		| * Proyecto    : RQ 4657 - Soluciones Customer Focus: Auto-Atención / Trazabilidad.

		| * Responsable : Cesar Jimenez.

		| * RDC         : RQ-4657-14

		|

		| * Revisiones

		| * Fecha            Autor        Motivo del cambio                  RDC

		| ----------------------------------------------------------------------------

		| - 16/11/21    Gianmarcos Perez  Guardar estado correo seguridad    RQ 4657-14

	************/

	DECLARE

		reg RECORD;

		n_seq     bigint := nextval('order_movements_seq');

		v_tikect  text; 

	BEGIN 

		vo_ind:= 0;

		vo_msn:= 'Se registro correctamente!!';



		if ni_send_success = 1 then	

		update send_email set status_code = 9 where order_master_id = ni_order_master_id and status_code = 8;

		update order_master set flag_send_email_security = 1 where order_master_id = ni_order_master_id;

		end if;

		

		INSERT INTO order_movements(

		order_movements_id, order_id, date_movements, state_movements_id, responsible_code)

		VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, 6, 'TESS'); 

		INSERT INTO send_email(

		request_movements_id, order_master_id, 

		affair, destination_email, emails_cc, state_code_send, send_success, status_code)

		VALUES (n_seq, ni_order_master_id, vi_asunto, vi_destination_email, vi_emails_cc, 6, ni_send_success, ni_send_success);

				

		

	END

	$$;


ALTER FUNCTION public.sp_save_send_email_security(ni_order_master_id integer, ni_send_success integer, vi_asunto character varying, vi_destination_email character varying, vi_emails_cc character varying, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 281 (class 1255 OID 16440)
-- Name: sp_save_state_done_msa(integer, integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_state_done_msa(ni_order_master_id integer, ni_state integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    reg RECORD;
	n_seq     bigint := nextval('order_movements_seq');
	v_tikect  text; 
BEGIN 
    vo_ind:= 0;
    vo_msn:= 'Se registro correctamente!!';
	INSERT INTO order_movements(
	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)
	VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, ni_state, 'TESS'); 
    update order_master set estado_request = ni_state where order_master_id = ni_order_master_id;
	
END
$$;


ALTER FUNCTION public.sp_save_state_done_msa(ni_order_master_id integer, ni_state integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 282 (class 1255 OID 16441)
-- Name: sp_save_tikect_done_msa(integer, integer, character varying, integer, numeric, integer, integer); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_save_tikect_done_msa(ni_order_detail_id integer, ni_order_id integer, vi_product_id character varying, ni_quantity_products_return_real integer, ni_monto_affected_real numeric, ni_flag_return integer, ni_reason_operation_id integer, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$
DECLARE
    reg RECORD;
	n_seq     bigint := nextval('order_movements_seq');
	v_tikect  text; 
	n_state   integer:=4;
BEGIN 
    vo_ind:= 0;
    vo_msn:= 'Se registro correctamente!!';
	/*
	INSERT INTO order_movements(
	order_movements_id, order_id, date_movements, state_movements_id, responsible_code)
	VALUES (n_seq, ni_order_master_id, CURRENT_TIMESTAMP, n_state, 'TESS'); 
    update order_master set estado_request = n_state where order_master_id = ni_order_master_id;
	*/
	
    update order_detail set flag_return = ni_flag_return,
	  quantity_products_return_real = ni_quantity_products_return_real,
	  monto_affected_real = ni_monto_affected_real
	where order_master_id = ni_order_id and 
	  product_id  = vi_product_id

	;
	
END
$$;


ALTER FUNCTION public.sp_save_tikect_done_msa(ni_order_detail_id integer, ni_order_id integer, vi_product_id character varying, ni_quantity_products_return_real integer, ni_monto_affected_real numeric, ni_flag_return integer, ni_reason_operation_id integer, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 283 (class 1255 OID 16442)
-- Name: sp_sucursal_disponible(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_sucursal_disponible() RETURNS TABLE(sucursal character varying, direccion character varying, horario_atencion character varying, url_imagen character varying, url_map character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN 
	RETURN QUERY  
        SELECT
            a.sucursal,
	    a.direccion,
	    a.horario_atencion,
	    a.url_imagen,
            a.url_map
	FROM sucursales_dis a 
	WHERE a.estado = 1;
END;
$$;


ALTER FUNCTION public.sp_sucursal_disponible() OWNER TO intcouriersusr;

--
-- TOC entry 284 (class 1255 OID 16443)
-- Name: sp_sucursales(); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_sucursales() RETURNS TABLE(sucursal character varying, codigo character varying, estado integer)
    LANGUAGE plpgsql
    AS $$

BEGIN 

	RETURN QUERY  

        SELECT

            a.sucursal,

	    	a.codigo,

	    	a.estado

	FROM sucursales a 

	WHERE a.estado = 1
	order by a.sucursal ASC;

END;

$$;


ALTER FUNCTION public.sp_sucursales() OWNER TO intcouriersusr;

--
-- TOC entry 243 (class 1255 OID 16444)
-- Name: sp_update_qr(integer, character varying); Type: FUNCTION; Schema: public; Owner: intcouriersusr
--

CREATE FUNCTION public.sp_update_qr(ni_order_master_id integer, vi_qr character varying, OUT vo_ind integer, OUT vo_msn character varying) RETURNS record
    LANGUAGE plpgsql
    AS $$

DECLARE

    reg RECORD;

	n_seq     bigint := nextval('order_movements_seq');

	v_tikect  text; 

BEGIN 

    vo_ind:= 0;

    vo_msn:= 'Se registro correctamente!!';

    update order_master set id_qr = vi_qr where order_master_id = ni_order_master_id;

	

END

$$;


ALTER FUNCTION public.sp_update_qr(ni_order_master_id integer, vi_qr character varying, OUT vo_ind integer, OUT vo_msn character varying) OWNER TO intcouriersusr;

--
-- TOC entry 198 (class 1259 OID 16445)
-- Name: classification_products_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.classification_products_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.classification_products_seq OWNER TO intcouriersusr;

--
-- TOC entry 199 (class 1259 OID 16447)
-- Name: classification_products; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.classification_products (
    classification_products_id bigint DEFAULT nextval('public.classification_products_seq'::regclass) NOT NULL,
    division_id character varying(7),
    division character varying(90),
    department_code character varying(7),
    department character varying(90),
    line_code character varying(7),
    line character varying(90),
    is_transport integer,
    state_code integer DEFAULT 1,
    is_enchufable integer,
    is_return integer,
    condition character varying(5),
    area_code character varying,
    area character varying,
    sline_code character varying,
    sline character varying,
    plazo character varying,
    mostrar integer
);


ALTER TABLE public.classification_products OWNER TO intcouriersusr;

--
-- TOC entry 200 (class 1259 OID 16455)
-- Name: n_enchufable_days; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.n_enchufable_days (
    value_number bigint
);


ALTER TABLE public.n_enchufable_days OWNER TO intcouriersusr;

--
-- TOC entry 201 (class 1259 OID 16458)
-- Name: operation_type_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.operation_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.operation_type_seq OWNER TO intcouriersusr;

--
-- TOC entry 202 (class 1259 OID 16460)
-- Name: operation_type; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.operation_type (
    operation_type_id bigint DEFAULT nextval('public.operation_type_seq'::regclass) NOT NULL,
    description character varying(50) NOT NULL,
    state_code integer NOT NULL,
    created_at timestamp with time zone,
    added_by character varying(30) NOT NULL,
    updated_at timestamp with time zone,
    modified_by character varying(30)
);


ALTER TABLE public.operation_type OWNER TO intcouriersusr;

--
-- TOC entry 203 (class 1259 OID 16464)
-- Name: order_category; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.order_category (
    order_category_id bigint DEFAULT nextval('public.operation_type_seq'::regclass) NOT NULL,
    description character varying(50) NOT NULL,
    state_code integer NOT NULL,
    created_at timestamp with time zone,
    added_by character varying(30) NOT NULL,
    updated_at timestamp with time zone,
    modified_by character varying(30)
);


ALTER TABLE public.order_category OWNER TO intcouriersusr;

--
-- TOC entry 204 (class 1259 OID 16468)
-- Name: order_detail_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.order_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_detail_seq OWNER TO intcouriersusr;

--
-- TOC entry 205 (class 1259 OID 16470)
-- Name: order_detail; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.order_detail (
    order_detail_id bigint DEFAULT nextval('public.order_detail_seq'::regclass) NOT NULL,
    order_id bigint NOT NULL,
    product_type_id bigint NOT NULL,
    product_id character varying(30) NOT NULL,
    quantity_products integer NOT NULL,
    quantity_products_return integer NOT NULL,
    amount numeric(14,4),
    amount_affected numeric(14,4),
    operation_type_id integer NOT NULL,
    reason_operation_id integer NOT NULL,
    product_url character varying(180),
    flag_offers integer NOT NULL,
    offers character varying(70),
    product character varying(180),
    classification_products_id bigint,
    model character varying,
    size character varying,
    image character varying,
    brand character varying(150),
    quantity_products_return_real integer,
    amount_affected_real numeric(14,4),
    flag_return integer,
    price_by_unit numeric(14,4),
    days_expiration integer,
    expiration_date date,
    price_by_unit_total numeric(14,4),
    promotion_code character varying(20),
    promotion character varying(250),
    cupon_number character varying(50),
    promotion_discount_amount numeric(14,4),
    itemn_number integer,
    color character varying(100),
    suborder character varying,
    type_product character varying,
    seller_name character varying,
    seller_id character varying
);


ALTER TABLE public.order_detail OWNER TO intcouriersusr;

--
-- TOC entry 206 (class 1259 OID 16477)
-- Name: order_movements_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.order_movements_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_movements_seq OWNER TO intcouriersusr;

--
-- TOC entry 207 (class 1259 OID 16479)
-- Name: order_movements; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.order_movements (
    order_movements_id bigint DEFAULT nextval('public.order_movements_seq'::regclass) NOT NULL,
    order_id bigint NOT NULL,
    date_movements timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    state_movements_id integer NOT NULL,
    responsible_code character varying(30) NOT NULL
);


ALTER TABLE public.order_movements OWNER TO intcouriersusr;

--
-- TOC entry 208 (class 1259 OID 16484)
-- Name: order_operation_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.order_operation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_operation_seq OWNER TO intcouriersusr;

--
-- TOC entry 209 (class 1259 OID 16486)
-- Name: order_purchase_internet_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.order_purchase_internet_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_purchase_internet_seq OWNER TO intcouriersusr;

--
-- TOC entry 210 (class 1259 OID 16488)
-- Name: order_purchase_internet; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.order_purchase_internet (
    order_id bigint DEFAULT nextval('public.order_purchase_internet_seq'::regclass) NOT NULL,
    order_master_id bigint NOT NULL,
    number_order character varying(30) NOT NULL
);


ALTER TABLE public.order_purchase_internet OWNER TO intcouriersusr;

--
-- TOC entry 211 (class 1259 OID 16492)
-- Name: order_purchase_store_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.order_purchase_store_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_purchase_store_seq OWNER TO intcouriersusr;

--
-- TOC entry 212 (class 1259 OID 16494)
-- Name: order_purchase_store; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.order_purchase_store (
    order_id bigint DEFAULT nextval('public.order_purchase_store_seq'::regclass) NOT NULL,
    order_master_id bigint NOT NULL,
    sucursal character varying(10) NOT NULL,
    caja character varying(10) NOT NULL,
    purchase_date character varying(10) NOT NULL,
    transaccion character varying(10) NOT NULL
);


ALTER TABLE public.order_purchase_store OWNER TO intcouriersusr;

--
-- TOC entry 213 (class 1259 OID 16498)
-- Name: parameter_master; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.parameter_master (
    parameter_id bigint,
    description character varying(120),
    value_number bigint,
    value_decimal numeric(14,4),
    value_string character varying(20),
    status integer DEFAULT 1
);


ALTER TABLE public.parameter_master OWNER TO intcouriersusr;

--
-- TOC entry 214 (class 1259 OID 16502)
-- Name: product_blocked; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.product_blocked (
    id_product_bloc integer NOT NULL,
    cod_product character varying,
    product_name character varying,
    price double precision,
    status integer
);


ALTER TABLE public.product_blocked OWNER TO intcouriersusr;

--
-- TOC entry 215 (class 1259 OID 16508)
-- Name: product_blocked_id_product_bloc_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.product_blocked_id_product_bloc_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.product_blocked_id_product_bloc_seq OWNER TO intcouriersusr;

--
-- TOC entry 3215 (class 0 OID 0)
-- Dependencies: 215
-- Name: product_blocked_id_product_bloc_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: intcouriersusr
--

ALTER SEQUENCE public.product_blocked_id_product_bloc_seq OWNED BY public.product_blocked.id_product_bloc;


--
-- TOC entry 216 (class 1259 OID 16510)
-- Name: prospect_order_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.prospect_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prospect_order_seq OWNER TO intcouriersusr;

--
-- TOC entry 217 (class 1259 OID 16512)
-- Name: prospect_order; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.prospect_order (
    prospect_order_id bigint DEFAULT nextval('public.prospect_order_seq'::regclass) NOT NULL,
    purchase_type_id integer NOT NULL,
    identity_document character varying(20) NOT NULL,
    email character varying(80) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    coordinates character varying(30)
);


ALTER TABLE public.prospect_order OWNER TO intcouriersusr;

--
-- TOC entry 218 (class 1259 OID 16517)
-- Name: prospect_order_internet_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.prospect_order_internet_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prospect_order_internet_seq OWNER TO intcouriersusr;

--
-- TOC entry 219 (class 1259 OID 16519)
-- Name: prospect_order_internet; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.prospect_order_internet (
    order_id bigint DEFAULT nextval('public.prospect_order_internet_seq'::regclass) NOT NULL,
    prospect_order_id bigint NOT NULL,
    number_order character varying(30) NOT NULL
);


ALTER TABLE public.prospect_order_internet OWNER TO intcouriersusr;

--
-- TOC entry 220 (class 1259 OID 16523)
-- Name: prospect_order_store_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.prospect_order_store_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prospect_order_store_seq OWNER TO intcouriersusr;

--
-- TOC entry 221 (class 1259 OID 16525)
-- Name: prospect_order_store; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.prospect_order_store (
    order_id bigint DEFAULT nextval('public.prospect_order_store_seq'::regclass) NOT NULL,
    prospect_order_id bigint NOT NULL,
    sucursal character varying(10) NOT NULL,
    caja character varying(10) NOT NULL,
    purchase_date character varying(10) NOT NULL,
    transaccion character varying(10) NOT NULL
);


ALTER TABLE public.prospect_order_store OWNER TO intcouriersusr;

--
-- TOC entry 222 (class 1259 OID 16529)
-- Name: purchase_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.purchase_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_seq OWNER TO intcouriersusr;

--
-- TOC entry 223 (class 1259 OID 16531)
-- Name: purchase; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.purchase (
    purchase_id bigint DEFAULT nextval('public.purchase_seq'::regclass) NOT NULL,
    identity_document character varying(20) NOT NULL,
    email character varying(80) NOT NULL,
    number_order character varying(30) NOT NULL,
    sucursal character varying(10) NOT NULL,
    caja character varying(10) NOT NULL,
    purchase_date character varying(10) NOT NULL,
    transaccion character varying(10) NOT NULL,
    number_document bigint,
    comercio integer,
    purchase_type_id integer NOT NULL,
    number_products integer NOT NULL,
    number_products_unique integer,
    number_products_return integer,
    monto_total numeric(14,4) NOT NULL,
    monto_total_return numeric(14,4),
    monto_total_change numeric(14,4),
    status integer DEFAULT 2,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_id date DEFAULT CURRENT_DATE,
    coordinates character varying(30),
    credit_notes integer,
    ip_address character varying(80),
    cud character varying(50),
    forma_pago character varying(2),
    name_client character varying(150),
    email_client character varying(120)
);


ALTER TABLE public.purchase OWNER TO intcouriersusr;

--
-- TOC entry 224 (class 1259 OID 16541)
-- Name: purchase_detail_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.purchase_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_detail_seq OWNER TO intcouriersusr;

--
-- TOC entry 225 (class 1259 OID 16543)
-- Name: purchase_detail; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.purchase_detail (
    purchase_detail_id bigint DEFAULT nextval('public.purchase_detail_seq'::regclass) NOT NULL,
    purchase_id bigint NOT NULL,
    product_type_id bigint NOT NULL,
    product_id character varying(30) NOT NULL,
    quantity_products integer DEFAULT 0 NOT NULL,
    quantity_products_return integer DEFAULT 0 NOT NULL,
    monto numeric(14,4),
    monto_affected numeric(14,4),
    product_url character varying(180),
    product character varying(180),
    model character varying,
    size character varying,
    brand character varying(150),
    quantity_products_return_real integer,
    monto_affected_real numeric(14,4),
    flag_return integer,
    price_by_unit numeric(14,4),
    division_id character varying(30),
    area_id character varying(30),
    departamento_id character varying(30),
    linea_id character varying(30),
    sub_linea_id character varying(30),
    classification_products_id bigint,
    itemn_number integer,
    promotion_code integer,
    promotion character varying(180),
    cupon_number integer,
    promotion_discount_amount numeric(4,0),
    days_expiration integer,
    color character varying(100),
    code_delivery character varying(10),
    mode_delivery character varying(60),
    time_of_purchase character varying(30),
    name_client character varying(150),
    suborder character varying,
    type_product character varying,
    seller_name character varying,
    seller_id character varying
);


ALTER TABLE public.purchase_detail OWNER TO intcouriersusr;

--
-- TOC entry 226 (class 1259 OID 16552)
-- Name: purchase_return_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.purchase_return_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.purchase_return_seq OWNER TO intcouriersusr;

--
-- TOC entry 227 (class 1259 OID 16554)
-- Name: purchase_return; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.purchase_return (
    purchase_return_id bigint DEFAULT nextval('public.purchase_return_seq'::regclass) NOT NULL,
    purchase_id bigint NOT NULL,
    number_order character varying(30) NOT NULL,
    sucursal character varying(10) NOT NULL,
    caja character varying(10) NOT NULL,
    purchase_return_date character varying(10) NOT NULL,
    transaccion character varying(10) NOT NULL,
    number_products integer NOT NULL,
    number_products_unique integer,
    monto_total numeric(14,4) NOT NULL,
    status integer DEFAULT 2,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_id date DEFAULT CURRENT_DATE,
    ip_address character varying(80),
    number_document integer,
    comercio integer,
    chanel_origen integer DEFAULT 1
);


ALTER TABLE public.purchase_return OWNER TO intcouriersusr;

--
-- TOC entry 228 (class 1259 OID 16562)
-- Name: purchase_return_detail; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.purchase_return_detail (
    purchase_return_id bigint,
    purchase_id bigint NOT NULL,
    product_id character varying(30) NOT NULL,
    quantity_products integer DEFAULT 0 NOT NULL,
    mount numeric(14,4),
    itemn_number integer
);


ALTER TABLE public.purchase_return_detail OWNER TO intcouriersusr;

--
-- TOC entry 229 (class 1259 OID 16566)
-- Name: purchase_type; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.purchase_type (
    purchase_type_id bigint NOT NULL,
    description character varying(50) NOT NULL,
    state_code integer NOT NULL,
    created_at timestamp with time zone,
    added_by character varying(30) NOT NULL,
    updated_at timestamp with time zone,
    modified_by character varying(30)
);


ALTER TABLE public.purchase_type OWNER TO intcouriersusr;

--
-- TOC entry 230 (class 1259 OID 16569)
-- Name: send_email_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.send_email_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.send_email_seq OWNER TO intcouriersusr;

--
-- TOC entry 231 (class 1259 OID 16571)
-- Name: reason_operation; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.reason_operation (
    reason_operation_id bigint DEFAULT nextval('public.send_email_seq'::regclass) NOT NULL,
    operation_type_id bigint NOT NULL,
    description character varying(50) NOT NULL,
    state_code integer NOT NULL,
    created_at timestamp with time zone,
    added_by character varying(30) NOT NULL,
    updated_at timestamp with time zone,
    modified_by character varying(30)
);


ALTER TABLE public.reason_operation OWNER TO intcouriersusr;

--
-- TOC entry 232 (class 1259 OID 16575)
-- Name: send_email; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.send_email (
    send_email_id bigint DEFAULT nextval('public.send_email_seq'::regclass) NOT NULL,
    request_movements_id bigint NOT NULL,
    affair character varying(300) NOT NULL,
    destination_email character varying(280) NOT NULL,
    emails_cc character varying(280) NOT NULL,
    state_code_send integer NOT NULL,
    order_master_id bigint,
    send_success integer,
    status_code integer DEFAULT 1
);


ALTER TABLE public.send_email OWNER TO intcouriersusr;

--
-- TOC entry 233 (class 1259 OID 16583)
-- Name: state_movements_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.state_movements_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.state_movements_seq OWNER TO intcouriersusr;

--
-- TOC entry 234 (class 1259 OID 16585)
-- Name: state_movements; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.state_movements (
    state_movements_id bigint DEFAULT nextval('public.state_movements_seq'::regclass) NOT NULL,
    description character varying(50) NOT NULL,
    state_code integer NOT NULL,
    created_at timestamp with time zone,
    added_by character varying(30) NOT NULL,
    updated_at timestamp with time zone,
    modified_by character varying(30)
);


ALTER TABLE public.state_movements OWNER TO intcouriersusr;

--
-- TOC entry 235 (class 1259 OID 16589)
-- Name: status; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.status (
    "exists" boolean
);


ALTER TABLE public.status OWNER TO intcouriersusr;

--
-- TOC entry 236 (class 1259 OID 16592)
-- Name: sucursales_seq; Type: SEQUENCE; Schema: public; Owner: intcouriersusr
--

CREATE SEQUENCE public.sucursales_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sucursales_seq OWNER TO intcouriersusr;

--
-- TOC entry 237 (class 1259 OID 16594)
-- Name: sucursales; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.sucursales (
    id_sucursal bigint DEFAULT nextval('public.sucursales_seq'::regclass) NOT NULL,
    codigo character varying,
    sucursal character varying,
    estado integer
);


ALTER TABLE public.sucursales OWNER TO intcouriersusr;

--
-- TOC entry 238 (class 1259 OID 16601)
-- Name: sucursales_dis; Type: TABLE; Schema: public; Owner: intcouriersusr
--

CREATE TABLE public.sucursales_dis (
    id_sucursal bigint NOT NULL,
    direccion character varying,
    sucursal character varying,
    estado integer,
    horario_atencion character varying,
    url_imagen character varying,
    url_map character varying
);


ALTER TABLE public.sucursales_dis OWNER TO intcouriersusr;

--
-- TOC entry 3015 (class 2604 OID 16607)
-- Name: product_blocked id_product_bloc; Type: DEFAULT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.product_blocked ALTER COLUMN id_product_bloc SET DEFAULT nextval('public.product_blocked_id_product_bloc_seq'::regclass);


--
-- TOC entry 3041 (class 2606 OID 16609)
-- Name: classification_products pk_classification_products; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.classification_products
    ADD CONSTRAINT pk_classification_products PRIMARY KEY (classification_products_id);


--
-- TOC entry 3043 (class 2606 OID 16611)
-- Name: operation_type pk_operation_type; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.operation_type
    ADD CONSTRAINT pk_operation_type PRIMARY KEY (operation_type_id);


--
-- TOC entry 3045 (class 2606 OID 16613)
-- Name: order_category pk_order_category; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_category
    ADD CONSTRAINT pk_order_category PRIMARY KEY (order_category_id);


--
-- TOC entry 3063 (class 2606 OID 16615)
-- Name: purchase pk_purchase; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT pk_purchase PRIMARY KEY (purchase_id);


--
-- TOC entry 3066 (class 2606 OID 16617)
-- Name: purchase_detail pk_purchase_detail; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.purchase_detail
    ADD CONSTRAINT pk_purchase_detail PRIMARY KEY (purchase_detail_id);


--
-- TOC entry 3068 (class 2606 OID 16619)
-- Name: purchase_return pk_purchase_return; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.purchase_return
    ADD CONSTRAINT pk_purchase_return PRIMARY KEY (purchase_return_id);


--
-- TOC entry 3070 (class 2606 OID 16621)
-- Name: purchase_type pk_purchase_type; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.purchase_type
    ADD CONSTRAINT pk_purchase_type PRIMARY KEY (purchase_type_id);


--
-- TOC entry 3072 (class 2606 OID 16623)
-- Name: reason_operation pk_reason_operation; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.reason_operation
    ADD CONSTRAINT pk_reason_operation PRIMARY KEY (reason_operation_id);


--
-- TOC entry 3057 (class 2606 OID 16625)
-- Name: prospect_order pk_request_claim; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.prospect_order
    ADD CONSTRAINT pk_request_claim PRIMARY KEY (prospect_order_id);


--
-- TOC entry 3059 (class 2606 OID 16627)
-- Name: prospect_order_internet pk_request_claim_internet; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.prospect_order_internet
    ADD CONSTRAINT pk_request_claim_internet PRIMARY KEY (order_id);


--
-- TOC entry 3061 (class 2606 OID 16629)
-- Name: prospect_order_store pk_request_claim_store; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.prospect_order_store
    ADD CONSTRAINT pk_request_claim_store PRIMARY KEY (order_id);


--
-- TOC entry 3047 (class 2606 OID 16631)
-- Name: order_detail pk_request_detail; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT pk_request_detail PRIMARY KEY (order_detail_id);


--
-- TOC entry 3039 (class 2606 OID 16633)
-- Name: order pk_request_master; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT pk_request_master PRIMARY KEY (order_id);


--
-- TOC entry 3049 (class 2606 OID 16635)
-- Name: order_movements pk_request_movements; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_movements
    ADD CONSTRAINT pk_request_movements PRIMARY KEY (order_movements_id);


--
-- TOC entry 3051 (class 2606 OID 16637)
-- Name: order_purchase_internet pk_request_purchase_internet; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_purchase_internet
    ADD CONSTRAINT pk_request_purchase_internet PRIMARY KEY (order_id);


--
-- TOC entry 3053 (class 2606 OID 16639)
-- Name: order_purchase_store pk_request_purchase_store; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_purchase_store
    ADD CONSTRAINT pk_request_purchase_store PRIMARY KEY (order_id);


--
-- TOC entry 3074 (class 2606 OID 16641)
-- Name: send_email pk_send_email; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.send_email
    ADD CONSTRAINT pk_send_email PRIMARY KEY (send_email_id);


--
-- TOC entry 3076 (class 2606 OID 16643)
-- Name: state_movements pk_state_movements; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.state_movements
    ADD CONSTRAINT pk_state_movements PRIMARY KEY (state_movements_id);


--
-- TOC entry 3055 (class 2606 OID 16645)
-- Name: product_blocked product_blocked_pkey; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.product_blocked
    ADD CONSTRAINT product_blocked_pkey PRIMARY KEY (id_product_bloc);


--
-- TOC entry 3080 (class 2606 OID 16647)
-- Name: sucursales_dis sucursales_dis_pkey; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.sucursales_dis
    ADD CONSTRAINT sucursales_dis_pkey PRIMARY KEY (id_sucursal);


--
-- TOC entry 3078 (class 2606 OID 16649)
-- Name: sucursales sucursales_pkey; Type: CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.sucursales
    ADD CONSTRAINT sucursales_pkey PRIMARY KEY (id_sucursal);


--
-- TOC entry 3064 (class 1259 OID 16650)
-- Name: purchase_sucursal_idx; Type: INDEX; Schema: public; Owner: intcouriersusr
--

CREATE UNIQUE INDEX purchase_sucursal_idx ON public.purchase USING btree (sucursal, caja, purchase_date, transaccion, number_order);


--
-- TOC entry 3086 (class 2606 OID 16651)
-- Name: prospect_order fk_request_claim_and_request_movements_id; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.prospect_order
    ADD CONSTRAINT fk_request_claim_and_request_movements_id FOREIGN KEY (purchase_type_id) REFERENCES public.purchase_type(purchase_type_id);


--
-- TOC entry 3083 (class 2606 OID 16656)
-- Name: order_detail fk_request_detail_and_operation_type; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_request_detail_and_operation_type FOREIGN KEY (operation_type_id) REFERENCES public.operation_type(operation_type_id);


--
-- TOC entry 3084 (class 2606 OID 16661)
-- Name: order_detail fk_request_detail_and_reason_operation; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_request_detail_and_reason_operation FOREIGN KEY (reason_operation_id) REFERENCES public.reason_operation(reason_operation_id);


--
-- TOC entry 3081 (class 2606 OID 16666)
-- Name: order fk_request_master_and_request_movements_id; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT fk_request_master_and_request_movements_id FOREIGN KEY (purchase_type_id) REFERENCES public.purchase_type(purchase_type_id);


--
-- TOC entry 3082 (class 2606 OID 16671)
-- Name: order fk_request_master_and_state_movements; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT fk_request_master_and_state_movements FOREIGN KEY (estado_request) REFERENCES public.state_movements(state_movements_id);


--
-- TOC entry 3085 (class 2606 OID 16676)
-- Name: order_movements fk_request_movements_and_state_movements; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.order_movements
    ADD CONSTRAINT fk_request_movements_and_state_movements FOREIGN KEY (state_movements_id) REFERENCES public.state_movements(state_movements_id);


--
-- TOC entry 3087 (class 2606 OID 16681)
-- Name: send_email fk_rsend_email_and_request_movements; Type: FK CONSTRAINT; Schema: public; Owner: intcouriersusr
--

ALTER TABLE ONLY public.send_email
    ADD CONSTRAINT fk_rsend_email_and_request_movements FOREIGN KEY (request_movements_id) REFERENCES public.order_movements(order_movements_id);


-- Completed on 2022-05-05 20:08:55 UTC

--
-- PostgreSQL database dump complete
--

