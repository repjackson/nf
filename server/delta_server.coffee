Meteor.methods
    set_facets: (model_slug, force)->
        if Meteor.userId()
            delta = Docs.findOne
                model:'delta'
                _author_id:Meteor.userId()
        else
            delta = Docs.findOne
                model:'delta'
                _author_id:null
        # console.log 'delta doc', delta
        model = Docs.findOne
            model:'model'
            slug:model_slug

        # if model_slug is delta.model_filter
        #     return
        # else
        fields =
            Docs.find
                model:'field'
                parent_id:model._id

        Docs.update model._id,
            $inc: views: 1

        # console.log 'fields', fields.fetch()

        Docs.update delta._id,
            $set:model_filter:model_slug

        # Docs.update delta._id,
        #     $set:facets:[
        #         {
        #             key:'_timestamp_tags'
        #             filters:[]
        #             res:[]
        #         }
        #     ]
        Docs.update delta._id,
            $set:facets:[]
        for field in fields.fetch()
            if field.faceted is true
                # console.log field
                # if Meteor.user()
                # console.log _.intersection(Meteor.user().roles,field.view_roles)
                # if _.intersection(Meteor.user().roles,field.view_roles).length > 0
                Docs.update delta._id,
                    $addToSet:
                        facets: {
                            title:field.title
                            icon:field.icon
                            key:field.key
                            rank:field.rank
                            field_type:field.field_type
                            filters:[]
                            res:[]
                        }

        field_ids = _.pluck(fields.fetch(), '_id')

        Docs.update delta._id,
            $set:
                viewable_fields: field_ids
        Meteor.call 'fum', delta._id


    fum: (delta_id)->
        delta = Docs.findOne delta_id

        model = Docs.findOne
            model:'model'
            slug:delta.model_filter

        # console.log 'running fum,', delta, model
        built_query = {}
        if delta.search_query
            built_query.title = {$regex:"#{delta.search_query}", $options: 'i'}

        fields =
            Docs.find
                model:'field'
                parent_id:model._id
        # if model.collection and model.collection is 'users'
        #     built_query.roles = $in:[delta.model_filter]
        # else
        #     # unless delta.model_filter is 'post'
        built_query.model = delta.model_filter

        # if delta.model_filter is 'model'
        #     unless 'dev' in Meteor.user().roles
        #         built_query.view_roles = $in:Meteor.user().roles

        # if not delta.facets
        #     # console.log 'no facets'
        #     Docs.update delta_id,
        #         $set:
        #             facets: [{
        #                 key:'_keys'
        #                 filters:[]
        #                 res:[]
        #             }
        #             # {
        #             #     key:'_timestamp_tags'
        #             #     filters:[]
        #             #     res:[]
        #             # }
        #             ]
        #
        #     delta.facets = [
        #         key:'_keys'
        #         filters:[]
        #         res:[]
        #     ]
        #


        for facet in delta.facets
            if facet.filters.length > 0
                built_query["#{facet.key}"] = $all: facet.filters

        if model.collection and model.collection is 'users'
            total = Meteor.users.find(built_query).count()
        else
            total = Docs.find(built_query).count()
        # console.log 'built query', built_query
        # response
        # for facet in delta.facets
        #     values = []
        #     local_return = []

        #     # agg_res = Meteor.call 'agg', built_query, facet.key, model.collection
        #     # agg_res = Meteor.call 'agg', built_query, facet.key

        #     if agg_res
        #         Docs.update { _id:delta._id, 'facets.key':facet.key},
                    # { $set: 'facets.$.res': agg_res }
        if delta.sort_key
            # console.log 'found sort key', delta.sort_key
            sort_by = delta.sort_key
        else
            sort_by = 'views'

        if delta.sort_direction
            sort_direction = delta.sort_direction
        else
            sort_direction = -1
        if delta.limit
            limit = delta.limit
        else
            limit = 10
        modifier =
            {
                fields:_id:1
                limit:limit
                sort:"#{sort_by}":sort_direction
            }

        # results_cursor =
        #     Docs.find( built_query, modifier )

        if model and model.collection and model.collection is 'users'
            results_cursor = Meteor.users.find(built_query, modifier)
            # else
            #     results_cursor = global["#{model.collection}"].find(built_query, modifier)
        else
            results_cursor = Docs.find built_query, modifier


        # if total is 1
        #     result_ids = results_cursor.fetch()
        # else
        #     result_ids = []
        result_ids = results_cursor.fetch()
        # console.log result_ids

        Docs.update {_id:delta._id},
            {$set:
                total: total
                result_ids:result_ids
            }, ->
        return true


        # delta = Docs.findOne delta_id

    agg: (query, key, collection)->
        # console.log 'running agg', query
        limit=40
        options = { explain:false }
        pipe =  [
            { $match: query }
            { $project: "#{key}": 1 }
            { $unwind: "$#{key}" }
            { $group: _id: "$#{key}", count: $sum: 1 }
            { $sort: count: -1, _id: 1 }
            { $limit: limit }
            { $project: _id: 0, name: '$_id', count: 1 }
        ]
        if pipe
            if collection and collection is 'users'
                agg = Meteor.users.rawCollection().aggregate(pipe,options)
            else
                agg = global['Docs'].rawCollection().aggregate(pipe,options)
            # else
            res = {}
            if agg
                agg.toArray()
        else
            return null
