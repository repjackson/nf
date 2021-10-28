if Meteor.isClient
    Template.registerHelper 'source_products', () -> 
        Docs.find
            model:'product'
            source_id:@_id
    Template.registerHelper 'product_source', () -> 
        found = 
            Docs.findOne
                model:'source'
                _id:@source_id
        # console.log found
        found
    
    Router.route '/sources', (->
        @layout 'layout'
        @render 'sources'
        ), name:'sources'
    Router.route '/source/:doc_id', (->
        @layout 'layout'
        @render 'source_view'
        ), name:'source_view'
    
    Template.sources.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'source', ->
            
            
            
    Template.source_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    Template.source_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'source_products', Router.current().params.doc_id
    

    Template.source_view.helpers
        source_products:->
            Docs.find
                model:'product'
                source_id:@_id

    Template.source_view.events
        'click .add_source_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    source_id: Router.current().params.doc_id
            Router.go "/product/#{new_id}/edit"        
            
    Template.sources.events
        'click .add_source': ->
            new_id = 
                Docs.insert 
                    model:'source'
            
            Router.go "/source/#{new_id}/edit"
            
        
if Meteor.isServer
    Meteor.publish 'source_products', (source_id)->
        Docs.find   
            model:'product'
            source_id:source_id
            
            
if Meteor.isClient
    Router.route '/source/:doc_id/edit', (->
        @layout 'layout'
        @render 'source_edit'
        ), name:'source_edit'



    Template.source_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'menu_section'


    Template.source_edit.events
        'click .delete_source':->
            if confirm 'delete?'
                Docs.remove @_id
                Router.go "/sources"

            
    Template.source_edit.helpers
        all_shop: ->
            Docs.find
                model:'source'