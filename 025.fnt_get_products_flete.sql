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
    return query
        select cp.line_code as "lineaid", 's' || substring(cp.sline_code, 2, 7) as "sublineaid", cp."line"
        from public.classification_products cp
        where cp."line" like '%flete%'
           or cp.sline = 'bolsas-tiendas'
           or cp.sline = 'bolsas - tiendas';
end;
$$;
