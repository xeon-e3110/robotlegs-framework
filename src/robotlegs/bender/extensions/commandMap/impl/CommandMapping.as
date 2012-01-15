//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package robotlegs.bender.extensions.commandMap.impl
{
	import org.swiftsuspenders.Injector;
	import robotlegs.bender.extensions.commandMap.api.ICommandMapping;
	import robotlegs.bender.framework.guard.api.IGuardGroup;
	import robotlegs.bender.framework.guard.impl.GuardGroup;
	import robotlegs.bender.framework.hook.api.IHookGroup;
	import robotlegs.bender.framework.hook.impl.HookGroup;

	public class CommandMapping implements ICommandMapping
	{

		/*============================================================================*/
		/* Public Properties                                                          */
		/*============================================================================*/

		private var _commandClass:Class;

		public function get commandClass():Class
		{
			return _commandClass;
		}

		private var _guards:IGuardGroup;

		public function get guards():IGuardGroup
		{
			return _guards;
		}

		private var _hooks:IHookGroup;

		public function get hooks():IHookGroup
		{
			return _hooks;
		}

		/*============================================================================*/
		/* Constructor                                                                */
		/*============================================================================*/

		public function CommandMapping(injector:Injector, commandClass:Class)
		{
			_commandClass = commandClass;
			_guards = new GuardGroup(injector);
			_hooks = new HookGroup(injector);
		}

		/*============================================================================*/
		/* Public Functions                                                           */
		/*============================================================================*/

		public function withGuards(... guardClasses):ICommandMapping
		{
			_guards.add.apply(null, guardClasses)
			return this;
		}

		public function withHooks(... hookClasses):ICommandMapping
		{
			_hooks.add.apply(null, hookClasses)
			return this;
		}
	}
}