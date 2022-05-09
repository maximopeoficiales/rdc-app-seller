CREATE OR REPLACE FUNCTION fnt_get_products_flete()
    returns TABLE
            (
                lineaId    varchar,
                subLineaId text,
                line       varchar
            )
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
        select cp.line_code as "lineaId", 'S' || substring(cp.sline_code, 2, 7) as "subLineaId", cp."line"
        FROM public.classification_products cp
        WHERE cp."line" like '%FLETE%'
           OR cp.sline = 'BOLSAS-TIENDAS'
           OR cp.sline = 'BOLSAS - TIENDAS';
END;
$$;
