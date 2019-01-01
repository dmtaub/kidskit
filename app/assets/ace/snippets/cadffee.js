ace.define("ace/snippets/cadffee",["require","exports","module"], function(require, exports, module) {
"use strict";

exports.snippetText = "# Cube\n\
snippet cube(options)\n\
	cube\n\
		size: [${1:10,10,10}]\n\
		center: ${2:true} # bool or array\n\
		${3:#radius: 1} # if rounded\n\
# Sphere\n\
snippet sphere(options)\n\
	sphere\n\
		radius: ${1:5}\n\
		center: ${2:true} # bool or array\n\
		resolution: ${3:128}\n\
# Cylinder\n\
snippet cylinder(options)\n\
	cylinder\n\
		radius: ${1:5}\n\
		center: ${2:true} # bool or array\n\
		resolution: ${3:128}\n\
";
exports.scope = "cadffee";

});                (function() {
                    ace.require(["ace/snippets/cadffee"], function(m) {
                        if (typeof module == "object" && typeof exports == "object" && module) {
                            module.exports = m;
                        }
                    });
                })();
            