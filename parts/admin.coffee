Router.route '/admin', -> @render 'admin'
Router.route '/boh', -> @render 'boh'
Router.route '/foh', -> @render 'foh'
if Meteor.isClient 
    Template.foh.onCreated ->
        @autorun => @subscribe 'admin_settings', ->
        @autorun => @subscribe 'model_docs', 'foh_call', ->
    Template.boh.onCreated ->
        @autorun => @subscribe 'admin_settings', ->
        @autorun => @subscribe 'model_docs', 'foh_call', ->
            
    Template.foh.events
        'click .end_call': ->
            settings = Docs.findOne model:'admin_settings'
            Docs.update settings._id, 
                $set: foh_calling:false
        'click .call_help': ->
            settings = Docs.findOne model:'admin_settings'
            if settings
                Docs.update settings._id, 
                    $set: foh_calling:true
            else 
                Docs.insert 
                    model:'admin_settings'
            Docs.insert 
                model:'foh_call'
    Template.foh.events
            
    Template.boh.helpers
        admin_settings: ->
            Docs.findOne 
                model:'admin_settings'
    Template.foh.helpers
        admin_settings: ->
            Docs.findOne 
                model:'admin_settings'
        call_docs: ->
            Docs.find 
                model:'foh_call'
            
if Meteor.isServer
    Meteor.publish 'admin_settings', ->
        Docs.find 
            model:'admin_settings'