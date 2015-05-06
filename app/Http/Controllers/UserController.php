<?php namespace App\Http\Controllers;

use User as User;

class HomeController extends Controller {

	/*
	|--------------------------------------------------------------------------
	| Home Controller
	|--------------------------------------------------------------------------
	|
	| This controller renders your application's "dashboard" for users that
	| are authenticated. Of course, you are free to change or remove the
	| controller as you wish. It is just here to get your app started!
	|
	*/

	/**
	 * Create a new controller instance.
	 *
	 * @return void
	 */
	public function __construct()
	{

		$this->middleware('admin_auth_controller');
	}

	/**
	 * Show the application dashboard to the user.
	 *
	 * @return Response
	 */
	public function index()
	{
		return view('home');
	}
	
	public function show($username)
{
    //
    $user = User::where('username', $username)->first();
    $userData = User::find($user->id)->UserDetail;

    return View::make('user', array(
        'userData'  => $userData
    ))->with('user', $user);
}

public function profileImage($username){
    $user = User::where('username', $username)->first();
    $temp = $_FILES['upload']['tmp_name'];
    $image = $_FILES['upload']['name'];
    $ext = pathinfo($image, PATHINFO_EXTENSION);

    $newFilename = uniqid($user->id);

    if(!is_dir("images/$username/"))
    {
        mkdir("images/$username", 0777);
    }

    $img = Image::make($temp);

    $img->fit(130, 130);

    $src = "images/$username/$newFilename.$ext";

    $img->save($src);

    $query = User::find($user->id)->profileImage;
    $query->src = $src;
    $query->alt = $username . '\'s Profile Image';
    $query->save();
}

}
