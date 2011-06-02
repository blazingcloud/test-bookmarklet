// Copyright 2011 Blazing Cloud, blazingcloud.net
// @author John Olmstead
// @namespace
// @module      Bookmarklet
//
// 
// Salesforce Chatter REST API for status updates
//    Resource:             /chatter/feeds/news/me/feed-items
//    HTTP method:          POST
//    Request parameter:    text
//    Example:              /services/data/v22.0/chatter/feeds/news/me/feed-items?text=New+post
//    Returns:              Feed Item
// http://www.salesforce.com/us/developer/docs/chatterapipre/Content/connect_resources_how_to.htm

// key: 3MVG9y6x0357Hlee4DL3FGEieIHOksjW46jHdEh7Q1I9jW4K1RkxxfhlsPDpGI64gIzfJ6TWKtYVhgUuojI.d

var BlazingCloud = {};
BlazingCloud.Bookmarklet = (function(JQuery, document) {
    var DIALOG_URL = 'http://pure-wind-615.heroku.com/status.html';
    var sf_token, bookmark;
    var pairs = unescape(top.location.search.substring(1)).split(/\&/);
    for (var i in pairs) {
        var nameVal = pairs[i].split(/\=/);
        if (nameVal[0] == 'url')
            bookmark = nameVal[1];
        else if  (nameVal[0] == 'code')
            sf_token = nameVal[1];
    }
 

    var marklet = {
        dialogURL: DIALOG_URL,
        sfAuth: {
            url: 'https://login.salesforce.com/services/oauth2/authorize' +
            '?response_type=code' +
            '&redirect_uri=' + encodeURIComponent(DIALOG_URL) +
            '&client_id=' + encodeURIComponent('3MVG9y6x0357Hlee4DL3FGEieIKvD32laT1z5huSmZdEOcM78RomTQS7DjtljGYfrbMVAd.PEOAdoFcYLhFF.'),
            auth: ''
        },
        endpoint: 'https://na9.salesforce.com/services/data/v21.0/query/?q=SELECT Name FROM Account',
        //endpoint: 'https://na1.salesforce.com/services/data/v22.0/chatter/users/me',
        testing: false,
        waiting: false,

        url: bookmark,
        sf_token: sf_token,
        dialog: function () {
            jQuery.cookie('bookmark',document.location);

            var sf_token = jQuery.cookie('sf_token');

            var width=956,  height=580;
            var screenHeight = screen.height;
            var screenWidth = screen.width;
            var left = Math.round( (screenWidth/3)-(width/3) );
            var top = (screenHeight > height) ? Math.round((screenHeight/2) - (height/2) ) : 0;
            var shareWin = window.open(this.sfAuth.url,'share-win',
                'left='+left+',top='+top+',width='+width+
                ',height='+height+',personalbar=0,toolbar=0,scrollbars=1,resizable=1');
            shareWin.focus();
        },
        onReady: function() {
            
            this.bookmark = jQuery.cookie('bookmark');
            console.info("this.bookmark:   "+this.bookmark);
            console.info("TOKEN: " + this.sf_token);
            $('#submit-button').attr('disabled', false);
            $('#spinner').hide();
            $('#status').attr('value', mk.message());
            $('#msg').html( mk.shareMessage());
        },
        submit: function () {
            var self = this;
            this.showSpinner(true);
            setTimeout(function () {
                self.showSpinner(false)
            }, 2000);
            this.sendStatus();
        },

        sendStatus: function () {
            console.info("sending request to " + this.endpoint);
            $.ajax({
                type: "GET",
                url: this.endpoint,
                dataType: "script",
                contentType: 'application/x-www-form-urlencoded',
                success: this.onSuccess,
                error: this.onError,
                async: false,
                beforeSend : function (xhr) {
                    console.info("BEFORE SEND");
                    xhr.setRequestHeader('Authorization', 'OAuth xxx');
                }
            });
        },
        onError: function (jqXHR, textStatus, errorThrown) {
            console.error(errorThrown);
        },

        onSuccess: function (data, textStatus, jqXHR) {
            console.info(data);
        },

        test: function () {
            this.testing = true;
            this.send();
        },

        message: function () {
            return 'Check this link out:\n\n' + this.bookmark;
        },

        shareMessage: function () {
            return 'You are sharing <strong>' + this.bookmark + '</strong></a> on Salesforce Chatter';
        },

        showSpinner: function (val) {
            if (val && this.waiting)
                return;
            if (!val && !this.waiting)
                return;
            var content = $('#content');
            var spinner = $('#spinner');  
            if (content && spinner) {
                if (val) {
                    content.hide();
                    spinner.show();
                    this.waiting = true;
                    var self = this;
                    setTimeout(function () {
                        self.showSpinner(false);
                    }, 10000);
                } else {
                    content.show();
                    spinner.hide();
                    this.waiting = false;
                }
            }
        }
    };

    return marklet;
}(jQuery, document));


