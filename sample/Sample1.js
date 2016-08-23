
if( typeof module !== 'undefined' )
require( 'wRegexpObject' );

var _ = wTools;

var regexpObject = _.RegexpObject( 'xxx' );

console.log( 'regexpObject :',regexpObject );
console.log( 'regexpObject.test( "xxx" )',regexpObject.test( 'xxx' ) );
