
if( typeof module !== 'undefined' )
require( 'wRegexpObject' );
let _ = wTools;

var regexpObject = _.RegexpObject( 'abc', 'includeAny' );

console.log( 'regexpObject :\n' + _.entity.exportString( regexpObject ) );
console.log( 'regexpObject.test( "abc" ) :', regexpObject.test( 'abc' ) );
