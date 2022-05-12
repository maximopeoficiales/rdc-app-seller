create or replace function fnt_get_products_flete()
    returns table
            (
                lineaid    varchar,
                sublineaid text,
                line       varchar
            )
    language plpgsql
as
$$
begin
/*************
      | * descripcion : public.fnt_get_products_flete
      | * proposito   : obtiene los productos con flete.
      | * input parameters:
      | * output parameters:
      |   - <lineaid>                : id de linea 
      |   - <sublineaid>                  : id de la sublinea 
      |   - <line>                   : linea 
      | * autor       : gianmarcos perez rojas.
      | * proyecto    : rq 4707 - cambios y devoluciones –devuelve r
      | * responsable : cesar jimenez.
      | * rdc         : rq 4707
      |
      | * revisiones
      | * fecha            autor       motivo del cambio            rdc
      | ----------------------------------------------------------------------------
      | - 09/05/22    maximo apaza  modificacion de la función     rq 4707
      ************/
    return query
        select cp.line_code as "lineaid", 's' || substring(cp.sline_code, 2, 7) as "sublineaid", cp."line"
        from public.classification_products cp
        where cp."line" like '%flete%'
           or cp.sline = 'bolsas-tiendas'
           or cp.sline = 'bolsas - tiendas';
end;
$$;
