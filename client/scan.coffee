# QrScanner = require 'qr-scanner'

if Meteor.isClient
    Router.route '/scanner', (->
        @render 'scanner'
        ), name:'scanner'

    Template.scanner.onCreated ->

    Template.scanner.onRendered ->
        # console.log QrScanner
        # qr_scanner = new QrScanner('.vid', (result)=> console.log('decoded qr code:', result));

        
        
    Template.scanner.events
        # 'keyup .search_product': ->
        #     search = $('.search_product').val()
        #     if search.length > 2
        #         Session.set('product_search', search)
            
        'click .start': ->
            console.log qr_scanner
            qr_scanner.start()

        'click .stop': -> qr_scanner.stop()
        'click .check': -> qr_scanner.hasCamera()


            
            
    Template.scanner.helpers 

    Template.scanner.events


    Template.scanner.qrCode = -> qrScanner.message()
