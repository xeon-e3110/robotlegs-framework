//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.core.messaging
{
	import robotlegs.bender.core.async.safelyCallBack;

	public class MessageRunner
	{

		/*============================================================================*/
		/* Private Properties                                                         */
		/*============================================================================*/

		private var _message:Object;

		private var _handlers:Array;

		private var _callback:Function;

		private var _halt:Boolean;

		private var _errors:Array;

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function MessageRunner(message:Object, handlers:Array, callback:Function, flags:uint)
		{
			_message = message;
			_handlers = handlers.concat();
			_callback = callback;
			_halt = Boolean(flags & MessageDispatcher.HALT_ON_ERROR);
			const reverse:Boolean = Boolean(flags & MessageDispatcher.REVERSE);
			reverse || _handlers.reverse();
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function run():void
		{
			next();
		}

		/*============================================================================*/
		/* Private Functions                                                          */
		/*============================================================================*/

		private function next():void
		{
			// Try to keep things synchronous with a simple loop,
			// forcefully breaking out for async handlers and recursing.
			// We do this to avoid increasing the stack depth unnecessarily.
			var handler:Function;
			while (handler = _handlers.pop())
			{
				if (handler.length == 0) // sync handler: ()
				{
					handler();
				}
				else if (handler.length == 1) // sync handler: (message)
				{
					handler(_message);
				}
				else if (handler.length == 2) // sync or async handler: (message, callback)
				{
					var handled:Boolean;
					handler(_message, function(error:Object = null, msg:Object = null):void
					{
						// handler must not invoke the callback more than once
						if (handled)
							return;

						handled = true;
						if (error && !_halt)
						{
							_errors ||= [];
							_errors.push(error);
							error = null;
						}
						if (error || _handlers.length == 0)
						{
							_callback && safelyCallBack(_callback, error || _errors, _message);
						}
						else
						{
							next();
						}
					});
					// IMPORTANT: MUST break this loop with a RETURN. See top.
					return;
				}
				else // ERROR: this should NEVER happen
				{
					throw new Error("Bad handler signature");
				}
			}
			// If we got here then this loop finished synchronously.
			// Nobody broke out, so we are done.
			// This relies on the various return statements above. Be careful.
			_callback && safelyCallBack(_callback, null, _message);
		}
	}
}
