<?php namespace App\Http\Middleware;

use Closure;
use App;

class AdminGuardMiddleware {

	/**
	 * Handle an incoming request.
	 *
	 * @param  \Illuminate\Http\Request  $request
	 * @param  \Closure  $next
	 * @return mixed
	 */
	public function handle($request, Closure $next)
	{
		
	if($request->ip() === '192.168.10.1' or $request->header('X-Role-Admin') === 'SECRET')
    {
        return $next($request);
    }
	
	App::abort(401, 'Not authenticated');
	}

}
