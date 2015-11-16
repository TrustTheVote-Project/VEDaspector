// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery.fileDownload
//= require bootstrap
//= require turbolinks
//= require_tree .

function setupItemContainer(prefix) {
    var rowDeleteFunction = function(e) {
        var $row = $(this).closest(prefix + '-row');
        if ($row.siblings().size() == 0) {
            $row.find('input').val('');
            $row.find('textarea').val('');
        } else {
            $row.remove();
        }
    };

    $(prefix + '-row-delete').on('click', rowDeleteFunction);
    $(prefix + '-append').on('click', function(e) {
        var collection = $(this).closest(prefix);
        var $newItem = collection.find(prefix + '-row:first').clone();
        $newItem.find('input').val('');
        $newItem.find('textarea').val('');
        $newItem.find(prefix + '-row-delete').on('click', rowDeleteFunction);
        collection.find(prefix + '-row-container').append($newItem);
    });

}

function ready() {
    setupItemContainer('.string-collection');
    setupItemContainer('.internationalized-text');

    $('.download-button').on('click', function(e) {
        e.preventDefault();

        $('#modal-spinner .spinner-text').text('Generating download...');
        $('#modal-spinner').modal();

        $.fileDownload($(this).prop("href"), {
            successCallback: function (url) {
                $('#modal-spinner').modal('hide');
            },
            failCallback: function (url) {
                $('#modal-spinner').modal('hide');
                alert("An error occured, and the file could not be downloaded. Please check VEDaspector’s logs.");
            }
        });
    });

    $('.delete-button').on('click', function(e) {
        e.preventDefault();

        $('#modal-confirm .confirm-text').text('This will delete the current record from VEDaspector. This cannot be undone.');
        $('#modal-confirm').modal();

        $('#modal-confirm .confirm-button').click(function() {
            $('#modal-confirm').modal('hide');
            $('#modal-spinner').modal();
            $('#modal-spinner .spinner-text').text('Deleting...');

            $('#entity-delete-form').submit();
        });
    });

    $('[data-toggle="popover"]').popover({
        html : true,
        content: function() {
            var content = $(this).attr("data-popover-content");
            return $(content).clone().removeClass('display-none').html();
        }
    });
}

$(document).ready(ready);
$(document).on('page:load', ready);
