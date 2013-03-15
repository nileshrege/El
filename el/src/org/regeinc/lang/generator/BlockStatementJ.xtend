package org.regeinc.lang.generator

import org.regeinc.lang.el.BlockStatement
import org.regeinc.lang.el.Else
import org.regeinc.lang.el.Guard
import org.regeinc.lang.el.If
import org.regeinc.lang.el.While

class BlockStatementJ {
	private new(){		
	}
	static BlockStatementJ blockStatementJ
	def static BlockStatementJ instance(){
		if(blockStatementJ==null)
			blockStatementJ = new BlockStatementJ()
		return blockStatementJ
	}
	
	def compile(BlockStatement blockStatement)'''
		«IF blockStatement.whileBlock!=null»«compile(blockStatement.whileBlock)»«
		ELSEIF blockStatement.ifBlock!=null»«compile(blockStatement.ifBlock)»«
		ELSEIF  blockStatement.guardBlock!=null»«compile(blockStatement.guardBlock)»«ENDIF»
	'''

	def compile(While whyle)'''
		while(«ConditionJ::instance.compile(whyle.orCondition)»){
			«IF whyle.methodBody!=null»«MethodJ::instance.compile(whyle.methodBody)»«ENDIF»
		}
		'''

	def compile(If ef)'''
		if(«ConditionJ::instance.compile(ef.orCondition)»){
			«IF ef.methodBody!=null»«MethodJ::instance.compile(ef.methodBody)»«ENDIF»
		}«IF ef.elseBlock!=null»«compile(ef.elseBlock)»«ENDIF»
		'''

	def compile(Else els)'''
		else «IF(els.ifCondition!=null)»«compile(els.ifCondition)»«ELSE»{
			«IF els.methodBody!=null»«MethodJ::instance.compile(els.methodBody)»«ENDIF»
		}«ENDIF»
	'''

	def compile(Guard guard)'''
		try{
			«MethodJ::instance.compile(guard.methodBody)»
		}«FOR entity:guard.allEntity»catch(«entity.name» e){
			«guard.typeRef.name».handle(e);
		}«ENDFOR»
	'''
}