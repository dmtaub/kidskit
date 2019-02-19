// NOTE: This must be tab-indented to work properly :/
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
		r: ${1:5}\n\
		center: ${2:true} # bool or array\n\
# Cylinder\n\
snippet cylinder(options)\n\
	cylinder\n\
		r: ${1:5}\n\
		h: ${2:10}\n\
		center: ${3:true} # bool or array\n\
# Union\n\
snippet union(shape1, shape2, ...)\n\
	union(\n\
		${1:cube(1.5)}\n\
		${2:sphere()}\n\
		#etc\n\
	)\n\
# Difference\n\
snippet difference(shape1, shape2, ...)\n\
	difference(\n\
		${1:cube(1.5)}\n\
		${2:sphere()}\n\
		#etc\n\
	)\n\
# Intersection\n\
snippet intersection(shape1, shape2, ...)\n\
	intersection(\n\
		${1:cube(1.5)}\n\
		${2:sphere()}\n\
		#etc\n\
	)\n\
# Translate\n\
snippet translate([x, y, z], shapeOrModule)\n\
	translate(\n\
		[${1:0}, ${2:0}, ${3:5}],\n\
		${4:sphere()}\n\
	)\n\
";
exports.scope = "cadffee";

});                
(function() {
	ace.require(["ace/snippets/cadffee"], function(m) {
		if (typeof module == "object" && typeof exports == "object" && module) {
				module.exports = m;
		}
	});
})();
