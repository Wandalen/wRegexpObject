( function _RegExp_test_s_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  _.include( 'wTesting' );

  require( '../bclass/RegexpObject.s' );

}

var _ = _global_.wTools;

// shared variables
var ArrOfRegx1 = [ /0/, /1/, /2/ ],
  ArrOfRegx2 = [ /3/, /4/, /5/ ],
  ArrOfRegx3 = [ /6/, /7/, /8/ ],
  ArrOfRegx4 = [ /9/, /10/, /11/ ],
  ArrOfRegx5 = [ /12/, /13/, /14/ ],
  ArrOfRegx6 = [ /14/, /16/, /17/ ],
  ArrOfRegx7 = [ /18/, /19/, /20/ ],
  ArrOfRegx8 = [ /21/, /22/, /23/ ],

  src1 =
  {
    includeAny : ArrOfRegx1,
    includeAll : ArrOfRegx2,
    excludeAny : ArrOfRegx3,
    excludeAll : ArrOfRegx4
  },
  src2 =
  {
    includeAny : ArrOfRegx5,
    includeAll : ArrOfRegx6,
    excludeAny : ArrOfRegx7,
    excludeAll : ArrOfRegx8
  },
  src3 =
  {
    includeAny : [ /a0/, /a1/, /a2/ ],
    includeAll : [ /b0/, /c1/, /c2/ ],
    excludeAny : [ /c0/, /c1/, /c2/ ],
    excludeAll : [ /d0/, /d1/, /d2/ ]
  },
  wrongSrc =
  {
    includeAny : ArrOfRegx5,
    includeAll : ArrOfRegx6,
    excludeAny : ArrOfRegx7,
    excludeAll : ArrOfRegx8,
    excludeSome : [ /[^a]/ ]
  };

//

function regexpEscape( test )
{
  var simpleStr = 'hello world',
    specialCharacters = '.*+?^=!:${}()|[]/\\',
    simpleSent = 'Hello. How are you?',
    empty = '';

  var expected1 = '\\.\\*\\+\\?\\^\\=\\!\\:\\$\\{\\}\\(\\)\\|\\[\\]\\/\\\\',
    expected2 = "Hello\\. How are you\\?"

  test.case = 'escape simple str without spec. characters';
  var got = _.regexpEscape( simpleStr );
  test.identical( got, simpleStr );

  test.case = 'escape special characters';
  var got = _.regexpEscape( specialCharacters );
  test.identical( got, expected1 );

  test.case = 'escape simple sentences';
  var got = _.regexpEscape( simpleSent );
  test.identical( got, expected2 );

  test.case = 'escape empty string';
  var got = _.regexpEscape( empty );
  test.identical( got, empty );
}

//

function regexpMakeArray( test )
{
  var arrOfStr = [ 'hello', 'world' ],
    singleStr = 'hello',
    singleReg = /world/,
    wrongParam1 = null,
    wrongParam2 = [ 3, 4 ],
    expectedArr1 = [ /hello/, /world/ ],
    expectedArr2 = [ /hello/ ],
    expectedArr3 = [ singleReg ];

  function getSource( v )
  {
    return v.source;
  }

  test.case = 'argument is array of string';
  var got = _.regexpMakeArray( arrOfStr );
  test.identical( got.map( getSource ), expectedArr1.map( getSource ) );

  test.case = 'argument is array of regexp';
  var got = _.regexpMakeArray( ArrOfRegx1 );
  test.identical( got, ArrOfRegx1 );

  test.case = 'argument is single string';
  var got = _.regexpMakeArray( singleStr );
  test.identical( got.map( getSource ), expectedArr2.map( getSource ) );

  test.case = 'argument is single regexp';
  var got = _.regexpMakeArray( singleReg );
  test.identical( got, expectedArr3 );

  test.case = 'argument is empty arr';
  var got = _.regexpMakeArray( [] );
  test.identical( got, [] );

  if( !Config.debug )
  return;

  test.case = 'call without arguments';
  test.shouldThrowErrorSync( function()
  {
    _.regexpMakeArray();
  });

  test.case = 'call with wrong type argument';
  test.shouldThrowErrorSync( function()
  {
    _.regexpMakeArray( wrongParam1 );
  });

  test.case = 'call with wrong type argument';
  test.shouldThrowErrorSync( function()
  {
    _.regexpMakeArray( wrongParam2 );
  });

};

//

function regexpFrom( test )
{
  var simpleStr = 'hello',
    simpleReg = /world/,
    strWithSpChar = 'Hello. How are you?',
    wrongParam1 = null,
    expected1 = /hello/,
    expected2 = /Hello\. How are you\?/;


  test.case = 'argument is simple string';
  var got = _.regexpFrom( simpleStr );
  test.identical( got.source, expected1.source );

  test.case = 'argument is regexp';
  var got = _.regexpFrom( simpleReg );
  test.identical( got, simpleReg );

  test.case = 'argument is string with special characters';
  var got = _.regexpFrom( strWithSpChar );
  test.identical( got.source, expected2.source );

  if( !Config.debug )
  return;

  test.case = 'call without arguments';
  test.shouldThrowErrorSync( function()
  {
    _.regexpFrom();
  });

  test.case = 'call with wrong type argument';
  test.shouldThrowErrorSync( function()
  {
    _.regexpFrom( wrongParam1 );
  });

};

//

function regexpArrayAny( test )
{
  var strForTest1 = 'some text 5',
    wrongTypeArr = [ /a/, /b/, '5' ],
    expectedIndex = 2,
    defaultParam = true;

  test.case = 'regexp is found in str';
  var got = _.regexpArrayAny( ArrOfRegx2, strForTest1, false );
  test.identical( got, expectedIndex );

  test.case = 'regexp isn\'t found in str';
  var got = _.regexpArrayAny( ArrOfRegx3, strForTest1, false );
  test.identical( got, false );

  test.case = 'empty regexp array passed';
  var got = _.regexpArrayAny( [], strForTest1, defaultParam );
  test.identical( got, defaultParam );

  if( !Config.debug )
  return;

  test.case = 'missed all arguments';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAny()
  });

  test.case = 'missed one of arguments';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAny( ArrOfRegx2, strForTest1 )
  });

  test.case = 'first argument is not array';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAny( 'hello', strForTest1, false );
  });

  test.case = 'element of array is not regexp';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAny( wrongTypeArr, strForTest1, false );
  });

}

//

function regexpArrayAll( test )
{
  var strForTest1 = '012349',
    wrongTypeArr = [ /0/, /3/, '9' ],
    expectedIndex = 2,
    defaultParam = false;

  test.case = 'all regexp is found in str';
  var got = _.regexpArrayAll( ArrOfRegx1, strForTest1, false );
  test.identical( got, true );

  test.case = 'one of regexp isn\'t found in str';
  var got = _.regexpArrayAll( ArrOfRegx2, strForTest1, false );
  test.identical( got, expectedIndex );

  test.case = 'empty regexp array passed';
  var got = _.regexpArrayAll( [], strForTest1, defaultParam );
  test.identical( got, defaultParam );

  if( !Config.debug )
  return;

  test.case = 'missed all arguments';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAll()
  });

  test.case = 'missed one of arguments';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAll( ArrOfRegx2, strForTest1 )
  });

  test.case = 'first argument is not array';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAll( 'hello', strForTest1, false );
  });

  test.case = 'element of array is not regexp';
  test.shouldThrowErrorSync( function()
  {
    _.regexpArrayAll( wrongTypeArr, strForTest1, false );
  });

}

//

function test( test )
{
  var regexpObj1 =
    {
      includeAny : [ /2/, /6/, /7/ ],
      includeAll : [ /0/, /1/, /2/ ],
      excludeAny : [ /6/, /7/, /8/ ],
      excludeAll : [ /2/, /6/, /7/ ]
    },
    regexpObj2 =
    {
      includeAny : [ /9/, /6/, /7/ ], //
      includeAll : [ /0/, /1/, /2/ ],
      excludeAny : [ /6/, /7/, /8/ ],
      excludeAll : [ /2/, /6/, /7/ ]
    },
    regexpObj3 =
    {
      includeAny : [ /2/, /6/, /7/ ],
      includeAll : [ /0/, /6/, /2/ ], //
      excludeAny : [ /6/, /7/, /8/ ],
      excludeAll : [ /2/, /6/, /7/ ]
    },
    regexpObj4 =
    {
      includeAny : [ /2/, /6/, /7/ ],
      includeAll : [ /0/, /1/, /2/ ],
      excludeAny : [ /6/, /7/, /0/ ], //
      excludeAll : [ /2/, /6/, /7/ ]
    },
    regexpObj5 =
    {
      includeAny : [ /2/, /6/, /7/ ],
      includeAll : [ /0/, /1/, /2/ ],
      excludeAny : [ /6/, /7/, /8/ ],
      excludeAll : [ /0/, /1/, /2/ ] //
    },
    testStr = '012345';

  test.case = 'all regeps array are matched';
  var got = _.RegexpObject.test( regexpObj1, testStr );
  test.identical( got, true );

  test.case = 'includeAny parameter do not contains any regexp that matches the string';
  var got = _.RegexpObject.test( regexpObj2, testStr );
  test.identical( got, false );

  test.case = 'includeAll contains any regexp that do not matches the string';
  var got = _.RegexpObject.test( regexpObj3, testStr );
  test.identical( got, false );

  test.case = 'excludeAny contains any regexp that matches the test string';
  var got = _.RegexpObject.test( regexpObj4, testStr );
  test.identical( got, false );

  test.case = 'excludeAll contains regexps that all matches the test string';
  var got = _.RegexpObject.test( regexpObj4, testStr );
  test.identical( got, false );

  test.case = 'null';
  var got = _.RegexpObject.test( null, testStr );
  test.identical( got, true );

  /**/

  if( !Config.debug )
  return;

  test.case = 'missing arguments';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.test();
  });

  test.case = 'missing string for testing';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.test( regexpObj1 );
  });

  test.case = 'incorrect first argument';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.test( 1, testStr );
  });

  test.case = 'second argument is not a string';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.test( regexpObj1, 44 );
  });

}

//

function _regexpObjectExtend( test )
{
  var src1 =
      [
        {
          includeAny : ArrOfRegx1,
          includeAll : ArrOfRegx2,
          excludeAny : ArrOfRegx3,
          excludeAll : ArrOfRegx4
        }
      ],
    src2 =
      [
        {
          includeAny : ArrOfRegx1,
          includeAll : ArrOfRegx2,
          excludeAny : ArrOfRegx3,
          excludeAll : ArrOfRegx4
        },
        {
          includeAny : ArrOfRegx5,
          includeAll : ArrOfRegx6,
          excludeAny : ArrOfRegx7,
          excludeAll : ArrOfRegx8
        }
      ],

    wrongSrc1 =
    {
      includeAny : ArrOfRegx5,
      includeAll : ArrOfRegx6,
      excludeAny : ArrOfRegx7,
      excludeAll : ArrOfRegx8
    },
    wrongSrc2 = [ 'includeAny' ],
    wrongSrc3 =
      [
        {
          includeAny : ArrOfRegx5,
          includeAll : ArrOfRegx6,
          excludeAny : ArrOfRegx7,
          excludeAll : ArrOfRegx8,
          excludeSome : [ /[^a]/ ]
        }
      ],

    dst1 = {},
    dst2 =
    {
      includeAny : [ /a0/, /a1/, /a2/ ],
      includeAll : [ /b0/, /c1/, /c2/ ],
      excludeAny : [ /c0/, /c1/, /c2/ ],
      excludeAll : [ /d0/, /d1/, /d2/ ]
    },
    dst3 =
    {
      includeAny : [ /a0/, /a1/, /a2/ ],
      includeAll : [ /b0/, /c1/, /c2/ ],
      excludeAny : [ /c0/, /c1/, /c2/ ],
      excludeAll : [ /d0/, /d1/, /d2/ ]
    },

    expected1 = src1.slice().pop(),
    expected2 =
    {
      includeAny : src2[ 1 ].includeAny,
      includeAll : dst2.includeAll.concat( src2[ 0 ].includeAll, src2[ 1 ].includeAll ),
      excludeAny : dst2.excludeAny.concat( src2[ 0 ].excludeAny, src2[ 1 ].excludeAny ),
      excludeAll : src2[ 1 ].excludeAll
    },
    expected3 =
    {
      includeAny : dst3.includeAny.concat( src2[ 0 ].includeAny, src2[ 1 ].includeAny ),
      includeAll : dst3.includeAll.concat( src2[ 0 ].includeAll, src2[ 1 ].includeAll ),
      excludeAny : dst3.excludeAny.concat( src2[ 0 ].excludeAny, src2[ 1 ].excludeAny ),
      excludeAll : dst3.excludeAll.concat( src2[ 0 ].excludeAll, src2[ 1 ].excludeAll )
    },

    extendOpt1 =
    {
      dst : dst1,
      srcs : src1,
      shrinking : true
    },
    extendOpt2 =
    {
      dst : dst2,
      srcs : src2,
      shrinking : true
    },
    extendOpt3 =
    {
      dst : dst3,
      srcs : src2,
      shrinking : false
    },

    wrongOpt1 =
    {
      dst : dst1,
      srcs : src1,
    },
    wrongOpt2 =
    {
      dst : null,
      srcs : src1,
      shrinking : false
    },
    wrongOpt3 =
    {
      dst : dst3,
      srcs : wrongSrc1,
      shrinking : false
    },
    wrongOpt4 =
    {
      dst : {},
      srcs : wrongSrc2,
      shrinking : false
    },
    wrongOpt5 =
    {
      dst : {},
      srcs : wrongSrc3,
      shrinking : false
    };

  test.case = 'simple regexp objects extend with shrinking';
  var got = wRegexpObject._regexpObjectExtend( extendOpt1 );
  test.contains( got, expected1 );

  test.case = 'regexp objects extend with shrinking';
  var got = wRegexpObject._regexpObjectExtend( extendOpt2 );
  test.contains( got, expected2 );

  test.case = 'regexp objects extend without shrinking';
  var got = wRegexpObject._regexpObjectExtend( extendOpt3 );
  test.contains( got, expected3 );

  test.case = 'regexp objects extend without shrinking';
  var got = wRegexpObject._regexpObjectExtend( extendOpt3 );
  var expected = wRegexpObject( expected3 );
  debugger;
  test.identical( got, expected );
  debugger;

  /**/

  if( !Config.debug )
  return;


  // test.case = 'missing parameters in options argument';
  // test.shouldThrowErrorSync( function()
  // {
  //   debugger;
  //   wRegexpObject._regexpObjectExtend( wrongOpt1 );
  // });

  // test.case = 'options.dst is not object';
  // test.shouldThrowErrorSync( function()
  // {
  //   wRegexpObject._regexpObjectExtend( wrongOpt2 );
  // });

  test.case = 'options.srcs not wrapped into array';
  test.shouldThrowErrorSync( function()
  {
    wRegexpObject._regexpObjectExtend( wrongOpt3 );
  });

  test.case = 'element of options.srcs is not object';
  test.shouldThrowErrorSync( function()
  {
    wRegexpObject._regexpObjectExtend( wrongOpt4 );
  });

  test.case = 'element of options.srcs has wrong format : (extra property)';
  test.shouldThrowErrorSync( function()
  {
    wRegexpObject._regexpObjectExtend( wrongOpt5 );
  });

}

//

function broaden( test )
{
  var dst1 = {},
    dst2 =
    {
      includeAny : [ /a0/, /a1/, /a2/ ],
      includeAll : [ /b0/, /c1/, /c2/ ],
      excludeAny : [ /c0/, /c1/, /c2/ ],
      excludeAll : [ /d0/, /d1/, /d2/ ]
    },


    expected0 =
    {
      includeAny : [],
      includeAll : [],
      excludeAny : [],
      excludeAll : []
    },
    expected1 = src1,
    expected2 =
    {
      includeAny : dst2.includeAny.concat( src1.includeAny, src2.includeAny, src3.includeAny ),
      includeAll : dst2.includeAll.concat( src1.includeAll, src2.includeAll, src3.includeAll ),
      excludeAny : dst2.excludeAny.concat( src1.excludeAny, src2.excludeAny, src3.excludeAny ),
      excludeAll : dst2.excludeAll.concat( src1.excludeAll, src2.excludeAll, src3.excludeAll )
    };

  test.case = 'empty RegexpObject object broaden nothing (missed source for RegexpObject extend)';
  var got = wRegexpObject.broaden( {} );
  test.contains( got, expected0 );

  test.case = 'empty RegexpObject object broaden by single object';
  var got = wRegexpObject.broaden( dst1, src1 );
  test.contains( got, expected1 );

  test.case = 'RegexpObjec with existing data broaden by other RegexpObject objects';
  var got = wRegexpObject.broaden( dst2, src1, src2, src3 );
  test.contains( got, expected2 );

  if( !Config.debug )
  return;

  test.case = 'missed arguments';
  test.shouldThrowErrorSync( function()
  {
    wRegexpObject.broaden();
  });

  test.case = 'result (first passed) parameter in not object';
  test.shouldThrowErrorSync( function()
  {
    wRegexpObject.broaden( 'hello', src1 );
  });

  test.case = 'source for RegexpObject extend has extra parameter';
  test.shouldThrowErrorSync( function()
  {
    wRegexpObject.broaden( {}, wrongSrc );
  });

}

//

function shrink( test )
{
  var dst1 = {}
  var dst2 =
  {
    includeAny : [ /a0/, /a1/, /a2/ ],
    includeAll : [ /b0/, /c1/, /c2/ ],
    excludeAny : [ /c0/, /c1/, /c2/ ],
    excludeAll : [ /d0/, /d1/, /d2/ ]
  }
  var expected0 =
  {
    includeAny : [],
    includeAll : [],
    excludeAny : [],
    excludeAll : []
  }
  var expected1 = src1;
  var expected2 =
  {
    includeAny : src3.includeAny,
    includeAll : dst2.includeAll.concat( src1.includeAll, src2.includeAll, src3.includeAll ),
    excludeAny : dst2.excludeAny.concat( src1.excludeAny, src2.excludeAny, src3.excludeAny ),
    excludeAll : src3.excludeAll
  }

  test.case = 'empty RegexpObject object broaden nothing (missed source for RegexpObject extend)';
  var got = _.RegexpObject.shrink( {} );
  test.contains( got, expected0 );

  test.case = 'empty RegexpObject object broaden by single object';
  var got = _.RegexpObject.shrink( dst1, src1 );
  test.contains( got, expected1 );

  test.case = 'RegexpObjec with existing data broaden by other RegexpObject objects';
  var got = _.RegexpObject.shrink( dst2, src1, src2, src3 );
  test.contains( got, expected2 );

  if( !Config.debug )
  return;

  test.case = 'missed arguments';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.shrink();
  });

  test.case = 'result (first passed) parameter in not object';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.shrink( 'hello', src1 );
  });

  test.case = 'source for RegexpObject extend has extra parameter';
  test.shouldThrowErrorSync( function()
  {
    _.RegexpObject.shrink( {}, wrongSrc );
  });

};

//

var Self =
{

  name : 'Tools/mid/RegExp',
  silencing : 1,

  tests :
  {

    regexpEscape        : regexpEscape,
    regexpMakeArray     : regexpMakeArray,
    regexpFrom : regexpFrom,
    regexpArrayAny          : regexpArrayAny,
    regexpArrayAll          : regexpArrayAll,
    test          : test,
    _regexpObjectExtend : _regexpObjectExtend,
    broaden : broaden,
    shrink  : shrink

  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
_.Tester.test( Self.name );

})( );
