create function fnt_update_seller(id_p bigint, name_p varchar default null) returns jsonb
    language plpgsql
as
$$
    -- ***********************************************************************************************
    -- Descripcion: < Función para actualizar un seller >
    --
    -- Input Parameters: < _param - parámetros de creacion del distrito >
    --  <id_p>                        :identificador de la tabla seller.
    --  <name_p>                      :nombre del seller.
    -- Output Parameters: < jsonb - objeto(Seller) >
    --   - <json>                              : objeto de  Seller.
    -- * autor       : gianmarcos perez rojas.
    -- * proyecto    : rq 4707 - cambios y devoluciones –devuelve r
    -- * responsable : cesar jimenez.
    -- * rdc         : rq 4707
    -- * revisiones
    -- * fecha            autor       motivo del cambio            rdc
    -- ----------------------------------------------------------------------------
    -- - 10/05/22    maximo apaza  creación de la función     rq 4707
    -- ************
declare
    context text;
    data    jsonb  = '{}';
    error   jsonb  = '{}';
    _id     bigint = id_p;

begin
    if name_p is not null then
        update seller
        set name       = name_p,
            updated_at = current_timestamp
        where id = _id;
    end if;

    select fnt_retrieve_seller(_id) -> 'data' -> 0 into data;
    return jsonb_build_object('data', data, 'error', error);

exception
    when others then
        get stacked diagnostics context = pg_exception_context;
        select jsonb_build_object('code', sqlstate, 'name', sqlerrm, 'context', context) into error;
        return jsonb_build_object('data', data, 'error', error);

end;
$$;

